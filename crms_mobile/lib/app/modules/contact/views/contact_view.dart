import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_top_bar.dart';

/// Mirrors contact.html — the placeholder site. Its own screens are built later.
class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const AppTopBar(),
      drawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.blue500),
              const SizedBox(height: 16),
              Text(
                'contact.title'.tr,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navy900),
              ),
              const SizedBox(height: 8),
              Text(
                'contact.comingSoon'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
