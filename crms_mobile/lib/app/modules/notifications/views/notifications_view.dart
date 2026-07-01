import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/notification_center_controller.dart';
import '../../../data/format.dart';
import '../../../data/models/app_notification.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/error_banner.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final center = Get.find<NotificationCenterController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.navy900.withValues(alpha: 0.25),
        foregroundColor: AppColors.ink,
        title: Text('notifications.title'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          Obx(() {
            if (center.notifications.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: center.markAllRead,
              child: Text('notifications.markAllRead'.tr),
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => center.reload(),
          child: Obx(() {
            if (center.isLoading.value && center.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (center.errorMessage.value != null) ErrorBanner(center.errorMessage.value!),
                if (center.notifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: Text('notifications.empty'.tr, style: const TextStyle(color: AppColors.muted))),
                  )
                else
                  ...center.notifications.map((n) => _NotificationTile(n: n, center: center)),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final NotificationCenterController center;
  const _NotificationTile({required this.n, required this.center});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => center.delete(n.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : AppColors.blue500.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: n.isRead ? Colors.grey.shade200 : AppColors.blue500.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Icon(
            n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
            color: n.isRead ? AppColors.muted : AppColors.blue500,
          ),
          title: Text(n.message, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(formatDateTime(n.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ),
          onTap: () async {
            if (!n.isRead) await center.markRead(n.id);
            if (n.customerId != null) {
              Get.toNamed(Routes.caseDetail, arguments: n.customerId);
            }
          },
        ),
      ),
    );
  }
}
