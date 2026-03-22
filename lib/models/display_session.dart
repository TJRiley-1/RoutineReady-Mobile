class DisplaySession {
  final String id;
  final String schoolId;
  final String deviceId;
  final String deviceName;
  final String sessionType;
  final bool isActive;
  final DateTime lastHeartbeat;
  final DateTime createdAt;

  DisplaySession({
    required this.id,
    required this.schoolId,
    required this.deviceId,
    this.deviceName = 'Display',
    this.sessionType = 'display',
    this.isActive = true,
    required this.lastHeartbeat,
    required this.createdAt,
  });

  factory DisplaySession.fromJson(Map<String, dynamic> json) {
    return DisplaySession(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String? ?? 'Display',
      sessionType: json['session_type'] as String? ?? 'display',
      isActive: json['is_active'] as bool? ?? true,
      lastHeartbeat: DateTime.parse(json['last_heartbeat'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
