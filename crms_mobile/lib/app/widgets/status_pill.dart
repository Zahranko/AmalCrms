import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Mirrors .status-pill / .status-pill--active / .status-pill--inactive.
class StatusPill extends StatelessWidget {
  final bool isActive;
  final String? activeLabel;
  final String? inactiveLabel;

  const StatusPill({super.key, required this.isActive, this.activeLabel, this.inactiveLabel});

  @override
  Widget build(BuildContext context) {
    final label = isActive ? (activeLabel ?? 'state.active'.tr) : (inactiveLabel ?? 'state.disabled'.tr);
    final color = isActive ? AppColors.navy700 : AppColors.error;
    final bg = isActive ? AppColors.blue500.withOpacity(0.12) : AppColors.error.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
