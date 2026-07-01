import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/login_controller.dart';
import 'widgets/auth_field.dart';
import 'widgets/brand_panel.dart';
import 'widgets/submit_button.dart';

/// Mirrors CRMS/wwwroot/index.html. The .page grid collapses to a single
/// column under 920px in CSS; the same breakpoint is used here to decide
/// between the split desktop layout and the mobile-first single column.
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const _breakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _breakpoint;

            if (isWide) {
              return Row(
                children: [
                  const Expanded(flex: 21, child: BrandPanel()),
                  Expanded(
                    flex: 20,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: _FormCard(showLogo: false),
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
              child: Center(child: _FormCard(showLogo: true)),
            );
          },
        ),
      ),
    );
  }
}

class _FormCard extends GetView<LoginController> {
  final bool showLogo;

  const _FormCard({required this.showLogo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy900.withOpacity(0.35),
            blurRadius: 60,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Center(child: Image.asset('assets/images/amal-logo.webp', height: 56)),
            const SizedBox(height: 24),
          ],
          Text(
            'login.title'.tr,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.navy900),
          ),
          const SizedBox(height: 6),
          Text(
            'login.subtitle'.tr,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          Obx(() {
            final message = controller.errorMessage;
            if (message == null) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                border: Border.all(color: AppColors.error.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 13.5)),
            );
          }),
          AuthField(
            label: 'login.username'.tr,
            controller: controller.usernameController,
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          Obx(
            () => AuthField(
              label: 'login.password'.tr,
              controller: controller.passwordController,
              icon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.submit(),
              suffix: IconButton(
                icon: Icon(
                  controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.muted,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Obx(() => SubmitButton(isLoading: controller.isLoading, onPressed: controller.submit)),
          const SizedBox(height: 26),
          Text(
            'login.footer'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
