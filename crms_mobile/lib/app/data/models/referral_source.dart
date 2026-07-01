/// Mirrors ReferralSourceDto on the backend.
class ReferralSource {
  final int id;
  final String name;
  final bool isActive;

  ReferralSource({required this.id, required this.name, required this.isActive});

  factory ReferralSource.fromJson(Map<String, dynamic> json) => ReferralSource(
        id: json['id'] as int,
        name: json['name'] as String,
        isActive: json['isActive'] as bool,
      );
}
