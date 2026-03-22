import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/active_timeline.dart';
import '../../models/display_settings.dart';
import '../../models/theme_config.dart';
import '../../utils/theme_utils.dart';
import '../../utils/time_utils.dart';
import '../../widgets/display/task_card.dart';
import '../../widgets/display/transition_indicator.dart';

class HorizontalDisplay extends StatelessWidget {
  final ActiveTimeline timeline;
  final DisplaySettings displaySettings;
  final ThemeConfig theme;
  final int currentTaskIndex;
  final double elapsedInTask;

  const HorizontalDisplay({
    super.key,
    required this.timeline,
    required this.displaySettings,
    required this.theme,
    required this.currentTaskIndex,
    required this.elapsedInTask,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = parseHexColor(theme.timeCardAccentColor);
    final endAccentColor = theme.timeCardAccentColorAlt != null
        ? parseHexColor(theme.timeCardAccentColorAlt!)
        : accentColor;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Start time card
              _TimeCard(
                time: timeline.startTime,
                label: 'Start',
                accentColor: accentColor,
              ),
              const SizedBox(width: 8),
              // Tasks with transitions
              ...List.generate(timeline.tasks.length, (index) {
                final task = timeline.tasks[index];
                final isCurrent = index == currentTaskIndex;
                final isPast = index < currentTaskIndex;
                final transitionWidth = (task.width * 1.5);

                return Row(
                  children: [
                    TaskCard(
                      task: task,
                      theme: theme,
                      isCurrent: isCurrent,
                      isPast: isPast,
                      index: index,
                    ),
                    const SizedBox(width: 4),
                    TransitionIndicator(
                      displaySettings: displaySettings,
                      theme: theme,
                      taskDuration: task.duration,
                      elapsed: elapsedInTask,
                      isPast: isPast,
                      isActive: isCurrent,
                      width: transitionWidth,
                    ),
                    const SizedBox(width: 4),
                  ],
                );
              }),
              // End time card
              _TimeCard(
                time: calculateEndTime(timeline.startTime, timeline.tasks),
                label: 'End',
                accentColor: endAccentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String time;
  final String label;
  final Color accentColor;

  const _TimeCard({
    required this.time,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.clock, size: 48, color: accentColor),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
