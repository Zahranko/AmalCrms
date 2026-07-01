class UserSession {
  final String token;
  final String username;
  final String role;
  final DateTime expiresAt;

  UserSession({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        token: json['token'] as String,
        username: json['username'] as String,
        role: json['role'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'username': username,
        'role': role,
        'expiresAt': expiresAt.toIso8601String(),
      };
}
