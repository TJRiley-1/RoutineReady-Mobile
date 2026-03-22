import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/active_timeline.dart';
import '../models/display_settings.dart';
import '../models/task.dart';
import 'auth_provider.dart';
import 'school_provider.dart';

final realtimeProvider = Provider<RealtimeManager>((ref) {
  return RealtimeManager(ref);
});

class RealtimeManager {
  final Ref _ref;
  RealtimeChannel? _channel;

  RealtimeManager(this._ref);

  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  void subscribe(String schoolId) {
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
        .subscribe();
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
    _channel?.unsubscribe();
    _channel = null;
  }
}
