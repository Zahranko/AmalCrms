import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../data/nav_items.dart';
import '../data/services/language_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Mirrors the .drawer in nav.css / renderDrawerNav() in nav.js.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final session = authController.session.value;
    final role = session?.role;
    final currentRoute = Get.currentRoute;

    final activeWebsite = authController.activeWebsite.value;
    final canSwitch = (session?.websites.length ?? 0) > 1;
    final items = NavItems.itemsFor(activeWebsite?.key, role);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              child: Row(
                children: [
                  Image.asset('assets/images/amal-logo.webp', height: 30, fit: BoxFit.contain),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (activeWebsite != null)
              ListTile(
                leading: const Icon(Icons.apps_rounded, color: AppColors.blue500),
                title: Text(
                  activeWebsite.name,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.navy700),
                ),
                subtitle: canSwitch ? Text('website.switch'.tr, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)) : null,
                trailing: canSwitch ? const Icon(Icons.unfold_more_rounded, color: AppColors.muted, size: 20) : null,
                onTap: canSwitch
                    ? () {
                        Navigator.of(context).pop();
                        Get.toNamed(Routes.websitePicker);
                      }
                    : null,
              ),
            if (activeWebsite != null) const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: items.map((item) {
                  final isActive = item.route == currentRoute;
                  return Material(
                    color: isActive ? AppColors.blue500.withOpacity(0.08) : Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: isActive ? AppColors.blue500 : Colors.transparent, width: 3),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          item.labelKey.tr,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive ? AppColors.navy700 : AppColors.ink,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          if (!isActive) Get.offNamed(item.route);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.muted),
              title: Text(
                'lang.toggle'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
              ),
              onTap: () => Get.find<LanguageService>().toggleLanguage(),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'topbar.logout'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                authController.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
