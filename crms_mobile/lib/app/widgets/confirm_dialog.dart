import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Mirrors #confirm-modal - a small Yes/No dialog used for status toggles.
/// Returns true if the user confirmed, false/null otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(title),
      content: Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('action.cancel'.tr)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: danger ? AppColors.error : AppColors.blue500),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? 'action.confirm'.tr),
        ),
      ],
    ),
  );
  return result ?? false;
}
