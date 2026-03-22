import 'task.dart';

class TaskTemplate {
  final dynamic id;
  final String name;
  final String startTime;
  final String endTime;
  final List<Task> tasks;

  TaskTemplate({
    required this.id,
    required this.name,
    this.startTime = '08:00',
    this.endTime = '10:30',
    this.tasks = const [],
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'],
      name: json['name'] as String? ?? 'Untitled',
      startTime: json['startTime'] as String? ?? json['start_time'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '10:30',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  TaskTemplate copyWith({
    dynamic id,
    String? name,
    String? startTime,
    String? endTime,
    List<Task>? tasks,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tasks: tasks ?? this.tasks,
    );
  }
}
