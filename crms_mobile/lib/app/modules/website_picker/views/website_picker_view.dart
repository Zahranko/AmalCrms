import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/website.dart';
import '../../../data/services/language_service.dart';
import '../../../theme/app_colors.dart';

/// Mirrors websitePicker.html — shown after login when the user can access more
/// than one website, and reused as the switcher from the drawer.
class WebsitePickerView extends StatelessWidget {
  const WebsitePickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final websites = auth.session.value?.websites ?? const <Website>[];
    final activeId = auth.activeWebsite.value?.id;

    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/amal-logo.webp', height: 50, fit: BoxFit.contain),
                  const SizedBox(height: 18),
                  Text(
                    'website.pickTitle'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'website.pickSubtitle'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  ...websites.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WebsiteTile(
                        website: w,
                        selected: w.id == activeId,
                        onTap: () => auth.setActiveWebsite(w),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Get.find<LanguageService>().toggleLanguage(),
                    child: Text('lang.toggle'.tr),
                  ),
                  TextButton(
                    onPressed: auth.logout,
                    child: Text('topbar.logout'.tr, style: const TextStyle(color: AppColors.muted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebsiteTile extends StatelessWidget {
  final Website website;
  final bool selected;
  final VoidCallback onTap;

  const _WebsiteTile({required this.website, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = website.name.trim();
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Material(
      color: selected ? const Color(0xFFF0F9FE) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.blue500 : AppColors.fieldBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.navy700, AppColors.blue500]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(website.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 15)),
                    Text(website.key, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.blue500),
            ],
          ),
        ),
      ),
    );
  }
}
