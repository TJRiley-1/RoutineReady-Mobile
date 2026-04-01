enum UserRole {
  teacher,
  staff,
  display,
  schoolAdmin;

  static UserRole fromString(String value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      case 'staff':
        return UserRole.staff;
      case 'display':
        return UserRole.display;
      case 'school_admin':
        return UserRole.schoolAdmin;
      default:
        return UserRole.staff;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.schoolAdmin:
        return 'school_admin';
      default:
        return name;
    }
  }
}

class OrgMember {
  final String id;
  final String orgId;
  final String userId;
  final UserRole role;

  OrgMember({
    required this.id,
    required this.orgId,
    required this.userId,
    required this.role,
  });

  factory OrgMember.fromJson(Map<String, dynamic> json) {
    return OrgMember(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      userId: json['user_id'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'staff'),
    );
  }

  bool get canEdit => role == UserRole.teacher || role == UserRole.staff;
  bool get canSave => role == UserRole.teacher;
  bool get canAccessAdmin => role == UserRole.teacher;
  bool get isDisplayOnly => role == UserRole.display;
  bool get isSessionOnly => role == UserRole.staff;
}
