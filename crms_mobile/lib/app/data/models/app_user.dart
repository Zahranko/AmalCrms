/// Mirrors UserDto on the backend / UserDto rows rendered in userManage.js.
/// Tolerant of the leaner shape returned by the forward-targets endpoint
/// (id/username/role only).
class AppUser {
  final int id;
  final String username;
  final String role;
  final bool isActive;
  final bool notifyOnNewCase;
  final DateTime createdAt;
  final List<int> websiteIds;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    required this.notifyOnNewCase,
    required this.createdAt,
    this.websiteIds = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        username: json['username'] as String,
        role: json['role'] as String,
        isActive: json['isActive'] as bool? ?? true,
        notifyOnNewCase: json['notifyOnNewCase'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        websiteIds: ((json['websiteIds'] as List?) ?? const [])
            .map((e) => e as int)
            .toList(),
      );
}
