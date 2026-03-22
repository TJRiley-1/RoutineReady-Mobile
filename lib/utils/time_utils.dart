import '../models/task.dart';

int getTotalDuration(List<Task> tasks) {
  return tasks.fold(0, (sum, task) => sum + task.duration);
}

String calculateEndTime(String startTime, List<Task> tasks) {
  final parts = startTime.split(':').map(int.parse).toList();
  final totalMinutes = getTotalDuration(tasks);
  final endMinutes = parts[0] * 60 + parts[1] + totalMinutes;
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

  final parts = startTime.split(':').map(int.parse).toList();
  final startSeconds = parts[0] * 3600 + parts[1] * 60;

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
  if (isActive) return (elapsed / taskDuration * 100).clamp(0, 100);
  return 0;
}
