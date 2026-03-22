import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'auth_provider.dart';
import 'school_provider.dart';

const _deviceIdKey = 'routine_ready_device_id';

final deviceIdProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  var deviceId = await storage.read(key: _deviceIdKey);
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await storage.write(key: _deviceIdKey, value: deviceId);
  }
  return deviceId;
});

final sessionModeProvider = StateProvider<String?>((ref) => null);

final displaySessionProvider =
    AsyncNotifierProvider<DisplaySessionNotifier, SessionInfo?>(
        () => DisplaySessionNotifier());

class SessionInfo {
  final bool isRegistered;
  final bool slotAvailable;
  final int activeDisplayCount;
  final int maxDisplaySlots;

  SessionInfo({
    this.isRegistered = false,
    this.slotAvailable = true,
    this.activeDisplayCount = 0,
    this.maxDisplaySlots = 1,
  });
}

class DisplaySessionNotifier extends AsyncNotifier<SessionInfo?> {
  Timer? _heartbeatTimer;

  SupabaseClient get _client => ref.read(supabaseClientProvider);

  @override
  Future<SessionInfo?> build() async {
    ref.onDispose(() {
      _heartbeatTimer?.cancel();
    });
    return null;
  }

  Future<SessionInfo> registerSession(String sessionType) async {
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState == null) {
      return SessionInfo(slotAvailable: false);
    }

    final deviceId = await ref.read(deviceIdProvider.future);
    final schoolId = schoolState.school.id;

    // Check subscription limits
    final subRes = await _client
        .from('subscriptions')
        .select()
        .eq('school_id', schoolId)
        .limit(1)
        .maybeSingle();

    final maxSlots = subRes?['max_display_slots'] as int? ?? 1;

    if (sessionType == 'display') {
      // Count active display sessions (excluding this device)
      final countRes = await _client
          .from('display_sessions')
          .select('id')
          .eq('school_id', schoolId)
          .eq('session_type', 'display')
          .eq('is_active', true)
          .neq('device_id', deviceId);

      final activeCount = (countRes as List).length;

      if (activeCount >= maxSlots) {
        state = AsyncData(SessionInfo(
          slotAvailable: false,
          activeDisplayCount: activeCount,
          maxDisplaySlots: maxSlots,
        ));
        return state.value!;
      }
    }

    // Upsert session
    await _client.from('display_sessions').upsert(
      {
        'school_id': schoolId,
        'device_id': deviceId,
        'device_name': schoolState.school.deviceName,
        'session_type': sessionType,
        'is_active': true,
        'last_heartbeat': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'school_id,device_id',
    );

    // Start heartbeat
    _startHeartbeat(schoolId, deviceId);

    final info = SessionInfo(
      isRegistered: true,
      slotAvailable: true,
      activeDisplayCount: 0,
      maxDisplaySlots: maxSlots,
    );
    state = AsyncData(info);
    return info;
  }

  void _startHeartbeat(String schoolId, String deviceId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      try {
        await _client.from('display_sessions').update({
          'last_heartbeat': DateTime.now().toUtc().toIso8601String(),
        }).eq('school_id', schoolId).eq('device_id', deviceId);
      } catch (_) {}
    });
  }

  Future<void> endSession() async {
    _heartbeatTimer?.cancel();
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState == null) return;

    final deviceId = await ref.read(deviceIdProvider.future);

    try {
      await _client
          .from('display_sessions')
          .update({'is_active': false})
          .eq('school_id', schoolState.school.id)
          .eq('device_id', deviceId);
    } catch (_) {}

    state = const AsyncData(null);
  }
}
