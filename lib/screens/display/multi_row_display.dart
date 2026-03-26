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

        // Does this row contain the current task?
        final currentIsInRow = currentTaskIndex >= startIdx && currentTaskIndex < endIdx;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: _AutoScrollRow(
              scrollToActive: currentIsInRow,
              currentLocalIndex: currentIsInRow
                  ? (isReversed
                      ? endIdx - 1 - currentTaskIndex
                      : currentTaskIndex - startIdx)
                  : -1,
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

/// A row that auto-scrolls to keep the active task visible.
class _AutoScrollRow extends StatefulWidget {
  final bool scrollToActive;
  final int currentLocalIndex;
  final Widget child;

  const _AutoScrollRow({
    required this.scrollToActive,
    required this.currentLocalIndex,
    required this.child,
  });

  @override
  State<_AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<_AutoScrollRow> {
  final ScrollController _controller = ScrollController();
  int _lastIndex = -1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AutoScrollRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToActive &&
        widget.currentLocalIndex >= 0 &&
        widget.currentLocalIndex != _lastIndex) {
      _lastIndex = widget.currentLocalIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  void _scrollToActive() {
    if (!_controller.hasClients || _controller.position.maxScrollExtent == 0) return;

    // Estimate position: each item ~200px wide at 0.8 scale
    final approxItemWidth = 200 * 0.8 + 4; // task + gap
    final offset = widget.currentLocalIndex * approxItemWidth;
    final viewport = _controller.position.viewportDimension;
    final target = (offset - viewport / 2 + approxItemWidth / 2)
        .clamp(0.0, _controller.position.maxScrollExtent);

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: widget.child,
    );
  }
}
