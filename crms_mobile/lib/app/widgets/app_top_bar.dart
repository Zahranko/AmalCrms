import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/notification_center_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

// "HospitalManager" is the first multi-word role in the app — give it a
// translated, spaced label; other roles read fine as their raw value.
String _roleLabel(String role) => role == 'HospitalManager' ? 'role.hospitalManager'.tr : role;

/// Mirrors the .topbar in nav.css - logo, username + role badge, logout.
/// The hamburger/drawer icon is supplied automatically by Scaffold when a
/// `drawer` is set, so it isn't built manually here.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: AppColors.navy900.withOpacity(0.25),
      foregroundColor: AppColors.ink,
      titleSpacing: 4,
      title: Image.asset('assets/images/amal-logo.webp', height: 32, fit: BoxFit.contain),
      actions: [
        const _NotificationBell(),
        Obx(() {
          final session = authController.session.value;
          if (session == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _roleLabel(session.role),
                  style: const TextStyle(color: AppColors.navy700, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final center = Get.find<NotificationCenterController>();
    return Obx(() {
      final count = center.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: 'topbar.notifications'.tr,
            icon: const Icon(Icons.notifications_none_rounded, size: 27, color: AppColors.ink),
            onPressed: () => Get.toNamed(Routes.notifications),
          ),
          if (count > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      );
    });
  }
}
