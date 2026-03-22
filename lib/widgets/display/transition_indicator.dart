import 'package:flutter/material.dart';
import '../../data/transition_presets.dart';
import '../../models/display_settings.dart';
import '../../models/theme_config.dart';
import 'progress_dots.dart';
import 'mascot_road.dart';

class TransitionIndicator extends StatelessWidget {
  final DisplaySettings displaySettings;
  final ThemeConfig theme;
  final int taskDuration;
  final double elapsed;
  final bool isPast;
  final bool isActive;
  final double width;

  const TransitionIndicator({
    super.key,
    required this.displaySettings,
    required this.theme,
    required this.taskDuration,
    required this.elapsed,
    required this.isPast,
    required this.isActive,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (displaySettings.transitionType == 'mascot') {
      return MascotRoad(
        taskDuration: taskDuration,
        elapsed: isActive ? elapsed : 0,
        isPast: isPast,
        isActive: isActive,
        roadWidth: width,
        roadHeight: displaySettings.roadHeight,
        spriteEmoji: getSpriteEmoji(displaySettings.selectedSprite),
        selectedSurface: displaySettings.selectedSurface,
      );
    }

    return ProgressLine(
      taskDuration: taskDuration,
      elapsed: isActive ? elapsed : 0,
      isPast: isPast,
      isActive: isActive,
      lineWidth: width,
      theme: theme,
    );
  }
}
