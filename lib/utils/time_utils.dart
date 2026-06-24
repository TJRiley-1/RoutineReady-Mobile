import '../models/task.dart';

/// Parses an "HH:mm" string into hours/minutes, tolerating malformed input
/// (missing parts or non-numeric values fall back to 0) so a bad time never
/// throws in a render/progress path.
({int h, int m}) parseHm(String time) {
  final parts = time.split(':');
  final h = parts.isNotEmpty ? (int.tryParse(parts[0].trim()) ?? 0) : 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
  return (h: h, m: m);
}

int getTotalDuration(List<Task> tasks) {
  return tasks.fold(0, (sum, task) => sum + task.duration);
}

String calculateEndTime(String startTime, List<Task> tasks) {
  final (:h, :m) = parseHm(startTime);
  final totalMinutes = getTotalDuration(tasks);
  final endMinutes = h * 60 + m + totalMinutes;
  final endHours = (endMinutes ~/ 60) % 24;
  final endMins = endMinutes % 60;
  return '${endHours.toString().padLeft(2, '0')}:${endMins.toString().padLeft(2, '0')}';
}

({int currentTaskIndex, double elapsedInTask}) getCurrentTaskProgress(
  DateTime currentTime,
  String startTime,
  List<Task> tasks,
) {
  final currentSeconds =
      currentTime.hour * 3600 + currentTime.minute * 60 + currentTime.second;

  final (:h, :m) = parseHm(startTime);
  final startSeconds = h * 3600 + m * 60;

  final elapsedSeconds = currentSeconds - startSeconds;

  if (elapsedSeconds < 0) {
    return (currentTaskIndex: -1, elapsedInTask: 0.0);
  }

  int accumulatedTime = 0;
  for (int i = 0; i < tasks.length; i++) {
    final taskDurationSeconds = tasks[i].duration * 60;
    if (elapsedSeconds < accumulatedTime + taskDurationSeconds) {
      return (
        currentTaskIndex: i,
        elapsedInTask: (elapsedSeconds - accumulatedTime) / 60.0,
      );
    }
    accumulatedTime += taskDurationSeconds;
  }

  return (currentTaskIndex: tasks.length, elapsedInTask: 0.0);
}

String? getDayKey(int dayNumber) {
  const dayMap = {
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
  };
  return dayMap[dayNumber];
}

double getProgressPercentage(
    bool isPast, bool isActive, double elapsed, int taskDuration) {
  if (isPast) return 100;
  // Guard against a zero/negative duration: x / 0 is NaN, and Dart's
  // NaN.clamp() stays NaN, which poisons downstream layout math. Treat a
  // zero-length active task as complete.
  if (isActive) {
    return taskDuration <= 0 ? 100 : (elapsed / taskDuration * 100).clamp(0, 100);
  }
  return 0;
}
