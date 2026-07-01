/// Mirrors UserDto on the backend / UserDto rows rendered in userManage.js.
class AppUser {
  final int id;
  final String username;
  final String role;
  final bool isActive;
  final bool notifyOnNewCase;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.notifyOnNewCase,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        username: json['username'] as String,
        role: json['role'] as String,
        isActive: json['isActive'] as bool,
        notifyOnNewCase: json['notifyOnNewCase'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
