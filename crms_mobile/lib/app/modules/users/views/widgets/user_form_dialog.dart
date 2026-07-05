import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/app_user.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_dropdown_field.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/users_controller.dart';

const _roles = ['Employee', 'Manager', 'Admin', 'HospitalManager'];
const _roleLabels = ['Employee', 'Manager', 'Admin', 'Hospital Manager'];

/// Mirrors #user-modal / openUserModal() in dashboard.js.
Future<void> showUserFormDialog(BuildContext context, UsersController controller, {AppUser? user}) {
  final isEdit = user != null;
  final usernameController = TextEditingController(text: user?.username ?? '');
  final passwordController = TextEditingController();
  String role = user?.role ?? 'Employee';
  bool notifyOnNewCase = user?.notifyOnNewCase ?? false;
  // Website access: default a new user to the website the admin is currently in.
  final Set<int> selectedWebsiteIds = {
    ...(isEdit
        ? user.websiteIds
        : (controller.activeWebsiteId != null ? [controller.activeWebsiteId!] : const <int>[]))
  };
  String? error;
  bool loading = false;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> submit() async {
          final username = usernameController.text.trim();
          final password = passwordController.text;

          if (username.length < 3) {
            setState(() => error = 'Username must be at least 3 characters.');
            return;
          }
          if (!isEdit && password.length < 6) {
            setState(() => error = 'userForm.errorPassword'.tr);
            return;
          }

          setState(() {
            loading = true;
            error = null;
          });

          // Admins are all-access, so their explicit membership list is ignored.
          final websiteIds = role == 'Admin' ? const <int>[] : selectedWebsiteIds.toList();

          final result = isEdit
              ? await controller.updateUser(user.id,
                  username: username, role: role, notifyOnNewCase: notifyOnNewCase, websiteIds: websiteIds)
              : await controller.createUser(
                  username: username, password: password, role: role, websiteIds: websiteIds);

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
          title: Text(isEdit ? 'userForm.editTitle'.tr : 'userForm.addTitle'.tr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(label: 'userForm.username'.tr, controller: usernameController, autofocus: true),
                if (!isEdit) const SizedBox(height: 16),
                if (!isEdit)
                  AppTextField(label: 'userForm.password'.tr, controller: passwordController, obscureText: true),
                const SizedBox(height: 16),
                AppDropdownField(
                  label: 'userForm.role'.tr,
                  value: role,
                  options: _roles,
                  optionLabels: _roleLabels,
                  onChanged: (value) => setState(() => role = value),
                ),
                const SizedBox(height: 12),
                Text('userForm.websites'.tr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                if (role == 'Admin')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('userForm.websitesAdminNote'.tr,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  )
                else if (controller.websites.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('userForm.websitesNone'.tr,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  )
                else
                  ...controller.websites.map(
                    (w) => CheckboxListTile(
                      value: selectedWebsiteIds.contains(w.id),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          selectedWebsiteIds.add(w.id);
                        } else {
                          selectedWebsiteIds.remove(w.id);
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      activeColor: const Color(0xFF3B82F6),
                      title: Text(w.name, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                if (isEdit) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: notifyOnNewCase,
                    onChanged: (v) => setState(() => notifyOnNewCase = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    activeColor: const Color(0xFF3B82F6),
                    title: Text('userForm.notifyNewCase'.tr,
                        style: const TextStyle(fontSize: 14)),
                  ),
                ],
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
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('action.save'.tr),
            ),
          ],
        );
      },
    ),
  );
}
