import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/app_user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/status_pill.dart';
import '../controllers/users_controller.dart';
import 'widgets/reset_password_dialog.dart';
import 'widgets/user_form_dialog.dart';

/// Mirrors userManage.html / userManage.js.
class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUserFormDialog(context, controller),
        icon: const Icon(Icons.add),
        label: Text('action.addUser'.tr),
        backgroundColor: AppColors.blue500,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadUsers,
        child: Obx(() {
          if (controller.isLoading.value && controller.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Text(
                'users.title'.tr,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Create, edit, and manage staff accounts.',
                style: TextStyle(fontSize: 13.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              if (controller.errorMessage.value != null) _ErrorBanner(controller.errorMessage.value!),
              if (controller.users.isEmpty && !controller.isLoading.value)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('users.empty'.tr, style: const TextStyle(color: AppColors.muted))),
                )
              else
                ...controller.users.map((user) => _UserCard(user: user)),
            ],
          );
        }),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 13.5)),
    );
  }
}

class _UserCard extends GetView<UsersController> {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isSelf = user.username == controller.currentUsername;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink),
                  ),
                ),
                StatusPill(isActive: user.isActive),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${user.role} · Created ${_formatDate(user.createdAt)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => showUserFormDialog(context, controller, user: user),
                  child: Text('action.edit'.tr),
                ),
                TextButton(
                  onPressed: () => showResetPasswordDialog(context, controller, user),
                  child: Text('action.resetPassword'.tr),
                ),
                TextButton(
                  onPressed: isSelf && user.isActive ? null : () => _toggleStatus(context),
                  style: TextButton.styleFrom(foregroundColor: user.isActive ? AppColors.error : AppColors.blue500),
                  child: Text(user.isActive ? 'action.disable'.tr : 'action.enable'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context) async {
    final nextActive = !user.isActive;
    final confirmed = await showConfirmDialog(
      context,
      title: nextActive ? 'confirmUser.enableTitle'.tr : 'confirmUser.disableTitle'.tr,
      message: nextActive
          ? 'confirmUser.enableMsg'.trParams({'username': user.username})
          : 'confirmUser.disableMsg'.trParams({'username': user.username}),
      confirmLabel: nextActive ? 'action.enable'.tr : 'action.disable'.tr,
      danger: !nextActive,
    );
    if (!confirmed) return;

    final error = await controller.setStatus(user, nextActive);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
