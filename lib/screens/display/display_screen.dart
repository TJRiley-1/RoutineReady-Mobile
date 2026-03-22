import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/active_timeline.dart';
import '../../models/display_settings.dart';
import '../../models/theme_config.dart';
import '../../providers/school_provider.dart';
import '../../providers/realtime_provider.dart';
import '../../providers/session_provider.dart';
import '../../utils/theme_utils.dart';
import '../../utils/time_utils.dart';
import 'horizontal_display.dart';
import 'multi_row_display.dart';
import 'auto_pan_display.dart';

class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({super.key});

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  Timer? _timer;
  int _currentTaskIndex = -1;
  double _elapsedInTask = 0;

  @override
  void initState() {
    super.initState();
    // Enter immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Subscribe to realtime
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState != null) {
      ref.read(realtimeProvider).subscribe(schoolState.school.id);
    }

    // Start time tracking
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateProgress());
    _updateProgress();
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ref.read(realtimeProvider).unsubscribe();
    super.dispose();
  }

  void _updateProgress() {
    final schoolState = ref.read(schoolProvider).valueOrNull;
    if (schoolState == null) return;

    final progress = getCurrentTaskProgress(
      DateTime.now(),
      schoolState.timeline.startTime,
      schoolState.timeline.tasks,
    );

    if (mounted) {
      setState(() {
        _currentTaskIndex = progress.currentTaskIndex;
        _elapsedInTask = progress.elapsedInTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolState = ref.watch(schoolProvider).valueOrNull;
    if (schoolState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final timeline = schoolState.timeline;
    final settings = schoolState.displaySettings;
    final theme = getActiveTheme(schoolState.currentTheme, schoolState.customThemes);
    final scaleFactor = settings.scale / 100;

    return Scaffold(
      body: Stack(
        children: [
          // Scaled display container
          Container(
            decoration: BoxDecoration(
              gradient: getBackgroundGradient(theme),
            ),
            child: SizedBox(
              width: settings.width.toDouble(),
              height: settings.height.toDouble(),
              child: Transform.scale(
                scale: scaleFactor,
                alignment: Alignment.topLeft,
                child: _buildDisplayMode(timeline, settings, theme),
              ),
            ),
          ),
          // Admin button overlay
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => _exitToModeSelect(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('\u2699\uFE0F', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayMode(
    ActiveTimeline timeline,
    DisplaySettings settings,
    ThemeConfig theme,
  ) {
    switch (settings.mode) {
      case 'horizontal':
        return HorizontalDisplay(
          timeline: timeline,
          displaySettings: settings,
          theme: theme,
          currentTaskIndex: _currentTaskIndex,
          elapsedInTask: _elapsedInTask,
        );
      case 'multi-row':
        return MultiRowDisplay(
          timeline: timeline,
          displaySettings: settings,
          theme: theme,
          currentTaskIndex: _currentTaskIndex,
          elapsedInTask: _elapsedInTask,
        );
      case 'auto-pan':
      default:
        return AutoPanDisplay(
          timeline: timeline,
          displaySettings: settings,
          theme: theme,
          currentTaskIndex: _currentTaskIndex,
          elapsedInTask: _elapsedInTask,
        );
    }
  }

  void _exitToModeSelect() {
    ref.read(displaySessionProvider.notifier).endSession();
    ref.read(sessionModeProvider.notifier).state = null;
  }
}
