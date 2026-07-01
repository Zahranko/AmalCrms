/// Mirrors CaseDto on the backend — the row shape used by the cases list and
/// dashboard. A "case" is a patient lead (the old Customer entity).
class CaseSummary {
  final int id;
  final String name;
  final String phoneCountryCode;
  final String phoneNumber;
  final String? department;
  final String? procedure;
  final String? referralSource;
  final String status;
  final String? createdByUsername;
  final String? assignedToUsername;
  final String? forwardedToUsername;
  final String? forwardedByUsername;
  final bool hasPendingForward;
  final DateTime createdAt;

  CaseSummary({
    required this.id,
    required this.name,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.department,
    required this.procedure,
    required this.referralSource,
    required this.status,
    required this.createdByUsername,
    required this.assignedToUsername,
    required this.forwardedToUsername,
    required this.forwardedByUsername,
    required this.hasPendingForward,
    required this.createdAt,
  });

  factory CaseSummary.fromJson(Map<String, dynamic> json) => CaseSummary(
        id: json['id'] as int,
        name: json['name'] as String,
        phoneCountryCode: json['phoneCountryCode'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        department: json['department'] as String?,
        procedure: json['procedure'] as String?,
        referralSource: json['referralSource'] as String?,
        status: json['status'] as String? ?? 'Pending',
        createdByUsername: json['createdByUsername'] as String?,
        assignedToUsername: json['assignedToUsername'] as String?,
        forwardedToUsername: json['forwardedToUsername'] as String?,
        forwardedByUsername: json['forwardedByUsername'] as String?,
        hasPendingForward: json['hasPendingForward'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
