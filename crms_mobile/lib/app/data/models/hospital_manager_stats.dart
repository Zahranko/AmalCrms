class HospitalManagerStats {
  final DateTime? from;
  final DateTime? to;
  final int totalCases;
  final int successCount;
  final int failedCount;
  final double successPercent;
  final double failedPercent;
  final List<GroupStat> departments;
  final List<GroupStat> doctors;

  HospitalManagerStats({
    required this.from,
    required this.to,
    required this.totalCases,
    required this.successCount,
    required this.failedCount,
    required this.successPercent,
    required this.failedPercent,
    required this.departments,
    required this.doctors,
  });

  factory HospitalManagerStats.fromJson(Map<String, dynamic> json) => HospitalManagerStats(
        from: json['from'] != null ? DateTime.tryParse(json['from'] as String) : null,
        to: json['to'] != null ? DateTime.tryParse(json['to'] as String) : null,
        totalCases: json['totalCases'] as int? ?? 0,
        successCount: json['successCount'] as int? ?? 0,
        failedCount: json['failedCount'] as int? ?? 0,
        successPercent: (json['successPercent'] as num?)?.toDouble() ?? 0.0,
        failedPercent: (json['failedPercent'] as num?)?.toDouble() ?? 0.0,
        departments: (json['departments'] as List? ?? [])
            .map((e) => GroupStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        doctors: (json['doctors'] as List? ?? [])
            .map((e) => GroupStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One department's or one doctor's ticket counts + success rate
/// (mirrors the backend's GroupStatDto).
class GroupStat {
  final int id;
  final String name;
  final int totalCases;
  final int successCount;
  final int failedCount;
  final double successRate;

  GroupStat({
    required this.id,
    required this.name,
    required this.totalCases,
    required this.successCount,
    required this.failedCount,
    required this.successRate,
  });

  factory GroupStat.fromJson(Map<String, dynamic> json) => GroupStat(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        totalCases: json['totalCases'] as int? ?? 0,
        successCount: json['successCount'] as int? ?? 0,
        failedCount: json['failedCount'] as int? ?? 0,
        successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      );
}
