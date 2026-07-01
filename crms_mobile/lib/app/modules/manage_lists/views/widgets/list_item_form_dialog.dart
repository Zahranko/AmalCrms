import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_text_field.dart';

/// Add/edit dialog for every Manage Lists resource. Mirrors #list-item-modal.
Future<void> showListItemFormDialog(
  BuildContext context, {
  required String title,
  String? initialName,
  required Future<String?> Function(String name) onSubmit,
}) {
  final nameController = TextEditingController(text: initialName ?? '');
  String? error;
  bool loading = false;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> submit() async {
          final name = nameController.text.trim();
          if (name.length < 2) {
            setState(() => error = 'listItem.errorName'.tr);
            return;
          }

          setState(() {
            loading = true;
            error = null;
          });

          final result = await onSubmit(name);
          if (result == null) {
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          } else {
            setState(() {
              loading = false;
              error = result;
            });
          }
        }

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(label: 'listItem.name'.tr, controller: nameController, autofocus: true),
                if (error != null) ...[
                  const SizedBox(height: 14),
                  Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('action.cancel'.tr)),
            FilledButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('action.save'.tr),
            ),
          ],
        );
      },
    ),
  );
}
