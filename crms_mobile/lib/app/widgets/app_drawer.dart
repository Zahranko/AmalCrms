import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../data/nav_items.dart';
import '../data/services/language_service.dart';
import '../theme/app_colors.dart';

/// Mirrors the .drawer in nav.css / renderDrawerNav() in nav.js.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final role = authController.session.value?.role;
    final currentRoute = Get.currentRoute;

    final items = NavItems.items.where((item) => item.roles == null || item.roles!.contains(role)).toList();

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
          ],
        ),
      ),
    );
  }
}
