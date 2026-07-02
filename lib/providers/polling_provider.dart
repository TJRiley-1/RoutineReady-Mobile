import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'school_provider.dart';

final pollingProvider = Provider<PollingManager>((ref) {
  return PollingManager(ref);
});

/// Replaces a persistent realtime (WebSocket) subscription with periodic
/// polling. The display doesn't need instant updates — it's a wall-mounted
/// schedule board, not a chat app — and polling has no connection to keep
/// alive, so there's nothing for flaky classroom wifi to disrupt. Every tick
/// just calls the same full reload() the old realtime reconnect path used.
class PollingManager {
  final Ref _ref;
  Timer? _timer;
  String? _schoolId;

  static const _pollInterval = Duration(seconds: 20);

  PollingManager(this._ref);

  void start(String schoolId) {
    _schoolId = schoolId;
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  void _poll() {
    if (_schoolId == null) return;
    _ref.read(schoolProvider.notifier).reload();
  }

  void stop() {
    _schoolId = null;
    _timer?.cancel();
    _timer = null;
  }
}
