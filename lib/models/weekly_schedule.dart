class WeeklySchedule {
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;

  WeeklySchedule({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      monday: json['monday'] as String?,
      tuesday: json['tuesday'] as String?,
      wednesday: json['wednesday'] as String?,
      thursday: json['thursday'] as String?,
      friday: json['friday'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'monday': monday,
        'tuesday': tuesday,
        'wednesday': wednesday,
        'thursday': thursday,
        'friday': friday,
      };

  String? getForDay(String day) {
    switch (day) {
      case 'monday':
        return monday;
      case 'tuesday':
        return tuesday;
      case 'wednesday':
        return wednesday;
      case 'thursday':
        return thursday;
      case 'friday':
        return friday;
      default:
        return null;
    }
  }

  WeeklySchedule setForDay(String day, String? templateId) {
    return WeeklySchedule(
      monday: day == 'monday' ? templateId : monday,
      tuesday: day == 'tuesday' ? templateId : tuesday,
      wednesday: day == 'wednesday' ? templateId : wednesday,
      thursday: day == 'thursday' ? templateId : thursday,
      friday: day == 'friday' ? templateId : friday,
    );
  }

  WeeklySchedule remapIds(Map<String, String> idMap) {
    return WeeklySchedule(
      monday: monday != null && idMap.containsKey(monday) ? idMap[monday] : monday,
      tuesday: tuesday != null && idMap.containsKey(tuesday) ? idMap[tuesday] : tuesday,
      wednesday: wednesday != null && idMap.containsKey(wednesday) ? idMap[wednesday] : wednesday,
      thursday: thursday != null && idMap.containsKey(thursday) ? idMap[thursday] : thursday,
      friday: friday != null && idMap.containsKey(friday) ? idMap[friday] : friday,
    );
  }
}
