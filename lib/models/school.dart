class School {
  final String id;
  final String ownerId;
  final String? orgId;
  final String schoolName;
  final String className;
  final String teacherName;
  final String deviceName;

  School({
    required this.id,
    required this.ownerId,
    this.orgId,
    required this.schoolName,
    required this.className,
    required this.teacherName,
    this.deviceName = 'Display 1',
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      orgId: json['org_id'] as String?,
      schoolName: json['school_name'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? 'Display 1',
    );
  }

  Map<String, dynamic> toJson() => {
        'owner_id': ownerId,
        if (orgId != null) 'org_id': orgId,
        'school_name': schoolName,
        'class_name': className,
        'teacher_name': teacherName,
        'device_name': deviceName,
      };

  School copyWith({
    String? schoolName,
    String? className,
    String? teacherName,
    String? deviceName,
    String? orgId,
  }) {
    return School(
      id: id,
      ownerId: ownerId,
      orgId: orgId ?? this.orgId,
      schoolName: schoolName ?? this.schoolName,
      className: className ?? this.className,
      teacherName: teacherName ?? this.teacherName,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}
