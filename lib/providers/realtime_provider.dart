import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/active_timeline.dart';
import '../models/display_settings.dart';
import '../models/task.dart';
import 'auth_provider.dart';
import 'school_provider.dart';

/// Whether the realtime connection is currently live.
final realtimeConnectedProvider = StateProvider<bool>((ref) => false);

final realtimeProvider = Provider<RealtimeManager>((ref) {
  return RealtimeManager(ref);
});

class RealtimeManager {
  final Ref _ref;
  RealtimeChannel? _channel;
  String? _schoolId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnectDelay = 30; // seconds

  RealtimeManager(this._ref);

  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  void subscribe(String schoolId) {
    _schoolId = schoolId;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _connect(schoolId);
  }

  void _connect(String schoolId) {
    _channel?.unsubscribe();

    _channel = _client
        .channel('school_$schoolId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'active_timeline',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'school_id',
            value: schoolId,
          ),
          callback: (payload) {
            _handleTimelineChange(payload);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'display_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'school_id',
            value: schoolId,
          ),
          callback: (payload) {
            _handleDisplaySettingsChange(payload);
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _reconnectAttempts = 0;
            _ref.read(realtimeConnectedProvider.notifier).state = true;
          } else if (status == RealtimeSubscribeStatus.closed ||
                     status == RealtimeSubscribeStatus.channelError) {
            _ref.read(realtimeConnectedProvider.notifier).state = false;
            _scheduleReconnect();
          }
        });
  }

  void _scheduleReconnect() {
    if (_schoolId == null) return; // Already unsubscribed intentionally

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s (capped)
    final delay = _reconnectAttempts <= 1
        ? 1
        : (1 << (_reconnectAttempts - 1)).clamp(1, _maxReconnectDelay);

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (_schoolId != null) {
        _connect(_schoolId!);
        // Re-fetch full data to catch anything missed while disconnected
        _ref.read(schoolProvider.notifier).reload();
      }
    });
  }

  void _handleTimelineChange(PostgresChangePayload payload) {
    final newData = payload.newRecord;
    if (newData.isEmpty) return;

    final schoolNotifier = _ref.read(schoolProvider.notifier);
    final timeline = ActiveTimeline(
      startTime: newData['start_time'] ?? '08:00',
      endTime: newData['end_time'] ?? '10:30',
      tasks: ((newData['tasks_json'] ?? []) as List)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
    schoolNotifier.updateTimeline(timeline);
  }

  void _handleDisplaySettingsChange(PostgresChangePayload payload) {
    final newData = payload.newRecord;
    if (newData.isEmpty) return;

    final schoolNotifier = _ref.read(schoolProvider.notifier);
    schoolNotifier.updateDisplaySettings(DisplaySettings.fromDbJson(newData));

    final newTheme = newData['current_theme'] as String?;
    if (newTheme != null) {
      schoolNotifier.updateCurrentTheme(newTheme);
    }
  }

  void unsubscribe() {
    _schoolId = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _channel?.unsubscribe();
    _channel = null;
    _ref.read(realtimeConnectedProvider.notifier).state = false;
  }
}
