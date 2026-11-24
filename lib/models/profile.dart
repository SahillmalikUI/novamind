class Profile {
  final String id;
  final String name;
  final String email;
  final String createdAt;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
