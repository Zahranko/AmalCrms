import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Mirrors STATUS_META in case.js / cases.js — maps a CustomerStatus string
/// to a label and a colour for the status pill.
class CaseStatusMeta {
  final String label;
  final Color color;
  final Color background;

  const CaseStatusMeta(this.label, this.color, this.background);
}

CaseStatusMeta caseStatusMeta(String status) {
  switch (status) {
    case 'Waiting':
      return CaseStatusMeta('status.waiting'.tr, const Color(0xFF9A6A00), const Color(0xFFFFF3D6));
    case 'Success':
      return CaseStatusMeta('status.success'.tr, const Color(0xFF1B7A43), const Color(0xFFDDF3E4));
    case 'Failed':
      return CaseStatusMeta('status.failed'.tr, AppColors.error, const Color(0xFFFBE0E2));
    case 'Pending':
      return CaseStatusMeta('status.pending'.tr, AppColors.navy700, AppColors.blue500.withValues(alpha: 0.12));
    default:
      return CaseStatusMeta(status, AppColors.navy700, AppColors.blue500.withValues(alpha: 0.12));
  }
}
