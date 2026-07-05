import 'package:get/get.dart';

/// Mirrors WebsiteDto on the backend — a tenant the user can enter.
class Website {
  final int id;
  final String key;
  final String nameEn;
  final String nameAr;

  Website({required this.id, required this.key, required this.nameEn, required this.nameAr});

  factory Website.fromJson(Map<String, dynamic> json) => Website(
        id: json['id'] as int,
        key: json['key'] as String? ?? '',
        nameEn: json['nameEn'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'key': key, 'nameEn': nameEn, 'nameAr': nameAr};

  /// Localized display name (follows the app language, falls back across both).
  String get name {
    final ar = Get.locale?.languageCode == 'ar';
    final primary = ar ? nameAr : nameEn;
    return primary.isNotEmpty ? primary : (ar ? nameEn : nameAr);
  }
}
