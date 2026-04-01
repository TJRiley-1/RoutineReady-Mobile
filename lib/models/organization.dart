class Organization {
  final String id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
