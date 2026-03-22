import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/active_timeline.dart';
import '../../models/display_settings.dart';
import '../../models/theme_config.dart';
import '../../widgets/display/task_card.dart';
import '../../widgets/display/transition_indicator.dart';

class MultiRowDisplay extends StatelessWidget {
  final ActiveTimeline timeline;
  final DisplaySettings displaySettings;
  final ThemeConfig theme;
  final int currentTaskIndex;
  final double elapsedInTask;

  const MultiRowDisplay({
    super.key,
    required this.timeline,
    required this.displaySettings,
    required this.theme,
    required this.currentTaskIndex,
    required this.elapsedInTask,
  });

  @override
  Widget build(BuildContext context) {
    final rows = displaySettings.rows;
    final tasksPerRow =
        (timeline.tasks.length / rows).ceil();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(rows, (rowIndex) {
        final startIdx = rowIndex * tasksPerRow;
        final endIdx = min((rowIndex + 1) * tasksPerRow, timeline.tasks.length);

        if (startIdx >= timeline.tasks.length) return const SizedBox.shrink();

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(endIdx - startIdx, (i) {
                  final index = startIdx + i;
                  final task = timeline.tasks[index];
                  final isCurrent = index == currentTaskIndex;
                  final isPast = index < currentTaskIndex;
                  final transitionWidth = task.width * 1.0;

                  return Row(
                    children: [
                      TaskCard(
                        task: task,
                        theme: theme,
                        isCurrent: isCurrent,
                        isPast: isPast,
                        index: index,
                      ),
                      if (i < endIdx - startIdx - 1) ...[
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
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      }),
    );
  }
}
