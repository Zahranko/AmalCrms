import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/app_user.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/users_controller.dart';

/// Mirrors #password-modal in dashboard.js.
Future<void> showResetPasswordDialog(BuildContext context, UsersController controller, AppUser user) {
  final passwordController = TextEditingController();
  String? error;
  bool loading = false;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> submit() async {
          final password = passwordController.text;
          if (password.length < 6) {
            setState(() => error = 'resetPassword.errorPassword'.tr);
            return;
          }

          setState(() {
            loading = true;
            error = null;
          });

          final result = await controller.resetPassword(user.id, password);

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
          title: Text('resetPassword.title'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a new password for ${user.username}.',
                style: const TextStyle(color: AppColors.muted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              AppTextField(label: 'resetPassword.newPassword'.tr, controller: passwordController, obscureText: true, autofocus: true),
              if (error != null) ...[
                const SizedBox(height: 14),
                Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('action.cancel'.tr)),
            FilledButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('resetPassword.title'.tr),
            ),
          ],
        );
      },
    ),
  );
}
