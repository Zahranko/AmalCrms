class AdminStats {
  final int totalCases;
  final int successCount;
  final int failedCount;
  final double successPercent;
  final double failedPercent;
  final List<ReferralSourceStat> referralSources;
  final List<EmployeeStat> employees;

  AdminStats({
    required this.totalCases,
    required this.successCount,
    required this.failedCount,
    required this.successPercent,
    required this.failedPercent,
    required this.referralSources,
    required this.employees,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        totalCases: json['totalCases'] as int? ?? 0,
        successCount: json['successCount'] as int? ?? 0,
        failedCount: json['failedCount'] as int? ?? 0,
        successPercent: (json['successPercent'] as num?)?.toDouble() ?? 0.0,
        failedPercent: (json['failedPercent'] as num?)?.toDouble() ?? 0.0,
        referralSources: (json['referralSources'] as List? ?? [])
            .map((e) => ReferralSourceStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        employees: (json['employees'] as List? ?? [])
            .map((e) => EmployeeStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ReferralSourceStat {
  final String name;
  final int count;
  final double percent;

  ReferralSourceStat({required this.name, required this.count, required this.percent});

  factory ReferralSourceStat.fromJson(Map<String, dynamic> json) => ReferralSourceStat(
        name: json['name'] as String? ?? '',
        count: json['count'] as int? ?? 0,
        percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      );
}

class EmployeeStat {
  final int userId;
  final String username;
  final int totalCreated;
  final int successCount;
  final int failedCount;
  final double percent;

  EmployeeStat({
    required this.userId,
    required this.username,
    required this.totalCreated,
    required this.successCount,
    required this.failedCount,
    required this.percent,
  });

  factory EmployeeStat.fromJson(Map<String, dynamic> json) => EmployeeStat(
        userId: json['userId'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        totalCreated: json['totalCreated'] as int? ?? 0,
        successCount: json['successCount'] as int? ?? 0,
        failedCount: json['failedCount'] as int? ?? 0,
        percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      );
}
