import 'task.dart';

class ActiveTimeline {
  final String startTime;
  final String endTime;
  final List<Task> tasks;

  ActiveTimeline({
    this.startTime = '08:00',
    this.endTime = '10:30',
    this.tasks = const [],
  });

  factory ActiveTimeline.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['tasks_json'] ?? json['tasks'] ?? [];
    return ActiveTimeline(
      startTime: json['start_time'] as String? ?? json['startTime'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? json['endTime'] as String? ?? '10:30',
      tasks: (tasksJson as List<dynamic>)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  ActiveTimeline copyWith({
    String? startTime,
    String? endTime,
    List<Task>? tasks,
  }) {
    return ActiveTimeline(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tasks: tasks ?? this.tasks,
    );
  }
}
