import 'package:flutter_test/flutter_test.dart';
import 'package:routine_ready/models/task.dart';
import 'package:routine_ready/utils/time_utils.dart';

/// Helper to build a task list with given durations (in minutes).
List<Task> _tasks(List<int> durations) {
  return durations
      .asMap()
      .entries
      .map((e) => Task(id: e.key, duration: e.value, content: 'Task ${e.key}'))
      .toList();
}

/// Helper to build a DateTime at a specific HH:MM:SS on an arbitrary date.
DateTime _time(int hour, int minute, [int second = 0]) {
  return DateTime(2026, 4, 6, hour, minute, second);
}

void main() {
  // ─── getTotalDuration ───

  group('getTotalDuration', () {
    test('empty task list returns 0', () {
      expect(getTotalDuration([]), 0);
    });

    test('single task', () {
      expect(getTotalDuration(_tasks([15])), 15);
    });

    test('multiple tasks', () {
      expect(getTotalDuration(_tasks([10, 20, 30])), 60);
    });
  });

  // ─── calculateEndTime ───

  group('calculateEndTime', () {
    test('basic end time calculation', () {
      // 08:00 + 150 minutes = 10:30
      expect(calculateEndTime('08:00', _tasks([30, 30, 30, 30, 30])), '10:30');
    });

    test('end time crosses noon', () {
      // 11:30 + 90 minutes = 13:00
      expect(calculateEndTime('11:30', _tasks([45, 45])), '13:00');
    });

    test('end time with zero-duration tasks', () {
      expect(calculateEndTime('09:00', _tasks([0, 0, 0])), '09:00');
    });

    test('end time wraps past midnight', () {
      // 23:00 + 120 minutes = 01:00 (next day, % 24)
      expect(calculateEndTime('23:00', _tasks([60, 60])), '01:00');
    });

    test('pads single-digit hours and minutes', () {
      // 00:05 + 3 minutes = 00:08
      expect(calculateEndTime('00:05', _tasks([3])), '00:08');
    });

    test('empty task list returns start time', () {
      expect(calculateEndTime('14:30', []), '14:30');
    });
  });

  // ─── getCurrentTaskProgress ───

  group('getCurrentTaskProgress', () {
    // Schedule: 08:00 start, tasks of 30, 20, 10 minutes
    final tasks = _tasks([30, 20, 10]);

    test('before start time returns index -1', () {
      final result = getCurrentTaskProgress(_time(7, 59, 59), '08:00', tasks);
      expect(result.currentTaskIndex, -1);
      expect(result.elapsedInTask, 0.0);
    });

    test('exactly at start time returns first task', () {
      final result = getCurrentTaskProgress(_time(8, 0, 0), '08:00', tasks);
      expect(result.currentTaskIndex, 0);
      expect(result.elapsedInTask, 0.0);
    });

    test('midway through first task', () {
      // 15 minutes into a 30-minute task
      final result = getCurrentTaskProgress(_time(8, 15, 0), '08:00', tasks);
      expect(result.currentTaskIndex, 0);
      expect(result.elapsedInTask, 15.0);
    });

    test('exactly at second task boundary', () {
      // 30 minutes in = start of second task
      final result = getCurrentTaskProgress(_time(8, 30, 0), '08:00', tasks);
      expect(result.currentTaskIndex, 1);
      expect(result.elapsedInTask, 0.0);
    });

    test('midway through second task', () {
      // 40 minutes in = 10 minutes into second task (20 min duration)
      final result = getCurrentTaskProgress(_time(8, 40, 0), '08:00', tasks);
      expect(result.currentTaskIndex, 1);
      expect(result.elapsedInTask, 10.0);
    });

    test('in last task', () {
      // 55 minutes in = 5 minutes into third task (starts at 50 min)
      final result = getCurrentTaskProgress(_time(8, 55, 0), '08:00', tasks);
      expect(result.currentTaskIndex, 2);
      expect(result.elapsedInTask, 5.0);
    });

    test('after all tasks returns index == tasks.length', () {
      // 60 minutes in = all tasks complete (total is 60 min)
      final result = getCurrentTaskProgress(_time(9, 0, 0), '08:00', tasks);
      expect(result.currentTaskIndex, tasks.length);
      expect(result.elapsedInTask, 0.0);
    });

    test('well after all tasks still returns tasks.length', () {
      final result = getCurrentTaskProgress(_time(12, 0, 0), '08:00', tasks);
      expect(result.currentTaskIndex, tasks.length);
    });

    test('handles sub-minute precision via seconds', () {
      // 30 seconds into the day = 0.5 minutes elapsed in first task
      final result = getCurrentTaskProgress(_time(8, 0, 30), '08:00', tasks);
      expect(result.currentTaskIndex, 0);
      expect(result.elapsedInTask, 0.5);
    });

    test('empty task list — at start time returns past-end', () {
      final result = getCurrentTaskProgress(_time(8, 0), '08:00', []);
      expect(result.currentTaskIndex, 0);
    });

    test('empty task list — before start time returns -1', () {
      final result = getCurrentTaskProgress(_time(7, 0), '08:00', []);
      expect(result.currentTaskIndex, -1);
    });

    test('single task schedule', () {
      final single = _tasks([45]);
      final result = getCurrentTaskProgress(_time(9, 20), '09:00', single);
      expect(result.currentTaskIndex, 0);
      expect(result.elapsedInTask, 20.0);
    });

    test('afternoon start time', () {
      final result = getCurrentTaskProgress(_time(14, 10), '14:00', tasks);
      expect(result.currentTaskIndex, 0);
      expect(result.elapsedInTask, 10.0);
    });
  });

  // ─── getDayKey ───

  group('getDayKey', () {
    test('Monday through Friday return correct keys', () {
      expect(getDayKey(1), 'monday');
      expect(getDayKey(2), 'tuesday');
      expect(getDayKey(3), 'wednesday');
      expect(getDayKey(4), 'thursday');
      expect(getDayKey(5), 'friday');
    });

    test('Saturday and Sunday return null', () {
      expect(getDayKey(6), isNull);
      expect(getDayKey(7), isNull);
    });

    test('out-of-range values return null', () {
      expect(getDayKey(0), isNull);
      expect(getDayKey(8), isNull);
      expect(getDayKey(-1), isNull);
    });
  });

  // ─── getProgressPercentage ───

  group('getProgressPercentage', () {
    test('past task returns 100', () {
      expect(getProgressPercentage(true, false, 0, 30), 100);
    });

    test('past task ignores other params', () {
      expect(getProgressPercentage(true, true, 15, 30), 100);
    });

    test('active task returns correct percentage', () {
      // 15 minutes elapsed of 30 minute task = 50%
      expect(getProgressPercentage(false, true, 15, 30), 50.0);
    });

    test('active task at start returns 0', () {
      expect(getProgressPercentage(false, true, 0, 30), 0.0);
    });

    test('active task at end returns 100', () {
      expect(getProgressPercentage(false, true, 30, 30), 100.0);
    });

    test('active task clamps to 100 if elapsed exceeds duration', () {
      expect(getProgressPercentage(false, true, 35, 30), 100.0);
    });

    test('active task clamps to 0 if elapsed is negative', () {
      expect(getProgressPercentage(false, true, -5, 30), 0.0);
    });

    test('future task returns 0', () {
      expect(getProgressPercentage(false, false, 0, 30), 0);
    });
  });
}
