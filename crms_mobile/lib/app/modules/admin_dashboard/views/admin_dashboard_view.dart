import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_stats.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/error_banner.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null && controller.stats.value == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ErrorBanner(controller.errorMessage.value!),
                const SizedBox(height: 12),
                TextButton(onPressed: controller.loadStats, child: Text('action.confirm'.tr)),
              ],
            ),
          );
        }
        final s = controller.stats.value;
        if (s == null) return const SizedBox.shrink();
        return RefreshIndicator(
          onRefresh: controller.loadStats,
          child: _AdminBody(stats: s),
        );
      }),
    );
  }
}

class _AdminBody extends GetView<AdminDashboardController> {
  final AdminStats stats;
  const _AdminBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        Text(
          'dashboard.title'.tr,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
        ),
        const SizedBox(height: 2),
        Text(
          controller.authController.session.value?.username ?? '',
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),

        // Summary cards
        _SectionHeader('admin.stats'.tr),
        Row(
          children: [
            _StatCard(label: 'admin.totalCases'.tr, value: '${stats.totalCases}', color: AppColors.blue500),
            _StatCard(
              label: 'admin.successRate'.tr,
              value: '${stats.successPercent.toStringAsFixed(0)}%',
              color: const Color(0xFF16a34a),
            ),
            _StatCard(
              label: 'admin.failedRate'.tr,
              value: '${stats.failedPercent.toStringAsFixed(0)}%',
              color: const Color(0xFFdc2626),
            ),
          ],
        ),

        // Referral sources
        _SectionHeader('admin.referralSources'.tr),
        if (stats.referralSources.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('admin.noData'.tr, style: const TextStyle(color: AppColors.muted)),
          )
        else
          ...stats.referralSources.map((r) => _ReferralRow(stat: r)),

        // Employee performance
        _SectionHeader('admin.employees'.tr),
        if (stats.employees.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('admin.noData'.tr, style: const TextStyle(color: AppColors.muted)),
          )
        else
          ...stats.employees.map((e) => _EmployeeRow(stat: e)),

        // Quick links
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(Routes.dashboard),
                icon: const Icon(Icons.list_alt_outlined, size: 18),
                label: Text('admin.viewAllCases'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy700,
                  side: const BorderSide(color: AppColors.fieldBorder),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed(Routes.userManage),
                icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                label: Text('admin.manageUsers'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy700,
                  side: const BorderSide(color: AppColors.fieldBorder),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.blue500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final ReferralSourceStat stat;
  const _ReferralRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(stat.name,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.ink)),
          ),
          Text('${stat.count}',
              style: const TextStyle(
                  color: AppColors.blue500, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text('${stat.percent.toStringAsFixed(0)}%',
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  final EmployeeStat stat;
  const _EmployeeRow({required this.stat});

  Color _rateColor(double p) {
    if (p >= 60) return const Color(0xFF16a34a);
    if (p >= 30) return const Color(0xFFd97706);
    return const Color(0xFFdc2626);
  }

  @override
  Widget build(BuildContext context) {
    final rateColor = _rateColor(stat.percent);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(
                  '${stat.totalCreated} total · ${stat.successCount} ✓ · ${stat.failedCount} ✗',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: rateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${stat.percent.toStringAsFixed(0)}%',
              style: TextStyle(color: rateColor, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
