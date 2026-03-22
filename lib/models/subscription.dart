class Subscription {
  final String id;
  final String schoolId;
  final String plan;
  final int maxDisplaySlots;
  final int maxAdminSlots;
  final String status;
  final DateTime? expiresAt;

  Subscription({
    required this.id,
    required this.schoolId,
    this.plan = 'free',
    this.maxDisplaySlots = 1,
    this.maxAdminSlots = 1,
    this.status = 'active',
    this.expiresAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      plan: json['plan'] as String? ?? 'free',
      maxDisplaySlots: json['max_display_slots'] as int? ?? 1,
      maxAdminSlots: json['max_admin_slots'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }
}
