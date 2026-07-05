/// Mirrors WebsiteSettingDto — one per-website "system parameter" (key/value).
class WebsiteSetting {
  final String key;
  final String value;

  WebsiteSetting({required this.key, required this.value});

  factory WebsiteSetting.fromJson(Map<String, dynamic> json) => WebsiteSetting(
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
