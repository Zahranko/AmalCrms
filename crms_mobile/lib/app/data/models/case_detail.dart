/// Mirrors CaseDetailDto on the backend — the full case view + its timeline.
class CaseDetail {
  final int id;
  final String name;
  final String phoneCountryCode;
  final String phoneNumber;
  final String referralSource;
  final String? procedure;
  final String description;
  final String status;
  final String? department;
  final bool hasDoctor;
  final String? doctor;
  final DateTime? appointmentDate;
  final String? createdByUsername;
  final String? assignedToUsername;
  final String? forwardedToUsername;
  final DateTime createdAt;
  final String? clinicSignature;
  final List<CaseAction> history;

  CaseDetail({
    required this.id,
    required this.name,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.referralSource,
    required this.procedure,
    required this.description,
    required this.status,
    required this.department,
    required this.hasDoctor,
    required this.doctor,
    required this.appointmentDate,
    required this.createdByUsername,
    required this.assignedToUsername,
    required this.forwardedToUsername,
    required this.createdAt,
    required this.clinicSignature,
    required this.history,
  });

  factory CaseDetail.fromJson(Map<String, dynamic> json) => CaseDetail(
        id: json['id'] as int,
        name: json['name'] as String,
        phoneCountryCode: json['phoneCountryCode'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        referralSource: json['referralSource'] as String? ?? '',
        procedure: json['procedure'] as String?,
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
        department: json['department'] as String?,
        hasDoctor: json['hasDoctor'] as bool? ?? false,
        doctor: json['doctor'] as String?,
        appointmentDate: json['appointmentDate'] == null
            ? null
            : DateTime.parse(json['appointmentDate'] as String),
        createdByUsername: json['createdByUsername'] as String?,
        assignedToUsername: json['assignedToUsername'] as String?,
        forwardedToUsername: json['forwardedToUsername'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        clinicSignature: json['clinicSignature'] as String?,
        history: (json['history'] as List? ?? [])
            .map((e) => CaseAction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Mirrors CaseActionDto — one entry on the case timeline.
class CaseAction {
  final int id;
  final String type;
  final String? resultingStatus;
  final String? actorUsername;
  final String? targetUsername;
  final DateTime? actionDate;
  final String? departmentName;
  final String? doctorName;
  final String? note;
  final DateTime createdAt;

  CaseAction({
    required this.id,
    required this.type,
    required this.resultingStatus,
    required this.actorUsername,
    required this.targetUsername,
    required this.actionDate,
    required this.departmentName,
    required this.doctorName,
    required this.note,
    required this.createdAt,
  });

  factory CaseAction.fromJson(Map<String, dynamic> json) => CaseAction(
        id: json['id'] as int,
        type: json['type'] as String? ?? '',
        resultingStatus: json['resultingStatus'] as String?,
        actorUsername: json['actorUsername'] as String?,
        targetUsername: json['targetUsername'] as String?,
        actionDate: json['actionDate'] == null
            ? null
            : DateTime.parse(json['actionDate'] as String),
        departmentName: json['departmentName'] as String?,
        doctorName: json['doctorName'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
