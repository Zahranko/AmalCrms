import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../theme/app_colors.dart';

/// Mirrors .brand-panel in styles.css — only shown on wide layouts
/// (the CSS hides it under a 920px media query).
class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.7, 1),
          colors: [AppColors.navy900, AppColors.navy700, AppColors.blue500],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, left: -70, child: _glow(AppColors.blue400.withOpacity(0.35), 320)),
          Positioned(bottom: -110, right: -90, child: _glow(AppColors.blue500.withOpacity(0.3), 360)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 16)),
                      ],
                    ),
                    child: Image.asset('assets/images/amal-logo.webp', height: 48),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'login.brandTitle'.tr,
                    style: const TextStyle(color: Color(0xFFEEF7FC), fontSize: 32, height: 1.25, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'login.brandSubtitle'.tr,
                    style: TextStyle(color: const Color(0xFFEEF7FC).withOpacity(0.85), fontSize: 15.5, height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  _Feature(icon: Icons.favorite_border, label: 'login.feature1'.tr),
                  const SizedBox(height: 18),
                  _Feature(icon: Icons.show_chart, label: 'login.feature2'.tr),
                  const SizedBox(height: 18),
                  _Feature(icon: Icons.shield_outlined, label: 'login.feature3'.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
