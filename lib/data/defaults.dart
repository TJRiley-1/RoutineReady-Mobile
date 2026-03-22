import '../models/task.dart';
import '../models/active_timeline.dart';
import '../models/template.dart';
import '../models/display_settings.dart';
import '../models/weekly_schedule.dart';

final List<Task> defaultTasks = [
  Task(id: 1, type: 'text', content: 'Task 1', duration: 30),
  Task(id: 2, type: 'text', content: 'Task 2', duration: 30),
  Task(id: 3, type: 'text', content: 'Task 3', duration: 30),
  Task(id: 4, type: 'text', content: 'Task 4', duration: 30),
  Task(id: 5, type: 'text', content: 'Task 5', duration: 30),
];

final ActiveTimeline defaultTimelineConfig = ActiveTimeline(
  startTime: '08:00',
  endTime: '10:30',
  tasks: defaultTasks,
);

final TaskTemplate defaultTemplate = TaskTemplate(
  id: 'default',
  name: 'Template 1',
  startTime: '08:00',
  endTime: '10:30',
  tasks: List.from(defaultTasks),
);

final defaultDisplaySettings = DisplaySettings();

final defaultWeeklySchedule = WeeklySchedule();

class SetupData {
  final String schoolName;
  final String className;
  final String teacherName;
  final String deviceName;
  final bool setupComplete;

  SetupData({
    this.schoolName = '',
    this.className = '',
    this.teacherName = '',
    this.deviceName = '',
    this.setupComplete = false,
  });

  SetupData copyWith({
    String? schoolName,
    String? className,
    String? teacherName,
    String? deviceName,
    bool? setupComplete,
  }) {
    return SetupData(
      schoolName: schoolName ?? this.schoolName,
      className: className ?? this.className,
      teacherName: teacherName ?? this.teacherName,
      deviceName: deviceName ?? this.deviceName,
      setupComplete: setupComplete ?? this.setupComplete,
    );
  }
}

final List<Task> trialTasks = [
  Task(id: 1, type: 'text', content: 'Morning Circle', duration: 30, icon: 'circle'),
  Task(id: 2, type: 'text', content: 'Maths', duration: 60, icon: 'calculator'),
  Task(id: 3, type: 'text', content: 'Lunch & Play', duration: 60, icon: 'utensils'),
  Task(id: 4, type: 'text', content: 'Reading', duration: 45, icon: 'book'),
  Task(id: 5, type: 'text', content: 'Outdoor Play', duration: 45, icon: 'tree'),
];
