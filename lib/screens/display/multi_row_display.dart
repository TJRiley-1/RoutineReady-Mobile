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
    final tasksPerRow = (timeline.tasks.length / rows).ceil();
    final isSnake = displaySettings.pathDirection == 'snake';
    const scale = 0.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(rows, (rowIndex) {
        final startIdx = rowIndex * tasksPerRow;
        final endIdx =
            min((rowIndex + 1) * tasksPerRow, timeline.tasks.length);

        if (startIdx >= timeline.tasks.length) return const SizedBox.shrink();

        final isReversed = isSnake && rowIndex.isOdd;
        final rowTasks = timeline.tasks.sublist(startIdx, endIdx);
        final displayTasks = isReversed ? rowTasks.reversed.toList() : rowTasks;

        // Calculate row start/end times
        final rowStartTime = _calculateTimeAtIndex(startIdx);
        final rowEndTime = _calculateTimeAtIndex(endIdx);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Row start time
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    child: Text(
                      isReversed ? rowEndTime : rowStartTime,
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  ...List.generate(displayTasks.length, (i) {
                    final actualIndex = isReversed
                        ? endIdx - 1 - i
                        : startIdx + i;
                    final task = displayTasks[i];
                    final isCurrent = actualIndex == currentTaskIndex;
                    final isPast = actualIndex < currentTaskIndex;
                    final transitionWidth = task.width * scale;

                    return Row(
                      children: [
                        Transform.scale(
                          scale: scale,
                          child: TaskCard(
                            task: task,
                            theme: theme,
                            isCurrent: isCurrent,
                            isPast: isPast,
                            index: actualIndex,
                          ),
                        ),
                        if (i < displayTasks.length - 1) ...[
                          const SizedBox(width: 2),
                          TransitionIndicator(
                            displaySettings: displaySettings,
                            theme: theme,
                            taskDuration: task.duration,
                            elapsed: elapsedInTask,
                            isPast: isPast,
                            isActive: isCurrent,
                            width: transitionWidth,
                          ),
                          const SizedBox(width: 2),
                        ],
                      ],
                    );
                  }),
                  // Row end time
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    child: Text(
                      isReversed ? rowStartTime : rowEndTime,
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String _calculateTimeAtIndex(int taskIndex) {
    if (taskIndex <= 0) return timeline.startTime;

    final parts = timeline.startTime.split(':');
    var totalMinutes =
        int.parse(parts[0]) * 60 + int.parse(parts[1]);

    for (var i = 0; i < taskIndex && i < timeline.tasks.length; i++) {
      totalMinutes += timeline.tasks[i].duration;
    }

    final h = (totalMinutes ~/ 60) % 24;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
