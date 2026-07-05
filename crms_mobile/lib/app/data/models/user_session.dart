import 'website.dart';

class UserSession {
  final String token;
  final String username;
  final String role;
  final DateTime expiresAt;
  final List<Website> websites;

  UserSession({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAt,
    this.websites = const [],
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        token: json['token'] as String,
        username: json['username'] as String,
        role: json['role'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        websites: ((json['websites'] as List?) ?? const [])
            .map((e) => Website.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'username': username,
        'role': role,
        'expiresAt': expiresAt.toIso8601String(),
        'websites': websites.map((w) => w.toJson()).toList(),
      };
}
