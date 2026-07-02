import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/format.dart';
import '../../../data/models/hospital_manager_stats.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/error_banner.dart';
import '../controllers/hospital_manager_dashboard_controller.dart';

class HospitalManagerDashboardView extends GetView<HospitalManagerDashboardController> {
  const HospitalManagerDashboardView({super.key});

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
          child: _Body(stats: s),
        );
      }),
    );
  }
}

class _Body extends GetView<HospitalManagerDashboardController> {
  final HospitalManagerStats stats;
  const _Body({required this.stats});

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: controller.fromDate.value != null && controller.toDate.value != null
          ? DateTimeRange(start: controller.fromDate.value!, end: controller.toDate.value!)
          : null,
    );
    if (picked != null) {
      controller.setCustomRange(picked.start, picked.end);
    }
  }

  String _periodLabel() {
    final from = stats.from;
    final to = stats.to;
    if (from == null && to == null) return 'hospitalManager.allTime'.tr;
    final fromLabel = from != null ? toApiDate(from) : 'hospitalManager.allTime'.tr;
    final toLabel = to != null ? toApiDate(to) : 'hospitalManager.allTime'.tr;
    return '$fromLabel – $toLabel';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hospitalManager.title'.tr,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                ),
                const SizedBox(height: 2),
                Text(
                  'hospitalManager.subtitle'.tr,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                _QuickFilterChips(onCustomTap: () => _pickCustomRange(context)),
                const SizedBox(height: 8),
                Text(
                  '${'hospitalManager.reportPeriod'.tr}: ${_periodLabel()}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(label: 'admin.totalCases'.tr, value: '${stats.totalCases}', color: AppColors.blue500),
                    _StatCard(
                      label: 'status.success'.tr,
                      value: '${stats.successPercent.toStringAsFixed(0)}%',
                      color: const Color(0xFF16a34a),
                    ),
                    _StatCard(
                      label: 'status.failed'.tr,
                      value: '${stats.failedPercent.toStringAsFixed(0)}%',
                      color: const Color(0xFFdc2626),
                    ),
                  ],
                ),
                _SectionHeader('hospitalManager.departments'.tr),
              ],
            ),
          ),
        ),
        _StatCardList(items: stats.departments),
        if (stats.departments.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: Text('admin.noData'.tr, style: const TextStyle(color: AppColors.muted))),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _SectionHeader('hospitalManager.doctors'.tr)),
        ),
        _StatCardList(items: stats.doctors),
        if (stats.doctors.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: Text('admin.noData'.tr, style: const TextStyle(color: AppColors.muted))),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          sliver: SliverToBoxAdapter(
            child: Text(
              'hospitalManager.exportHint'.tr,
              style: const TextStyle(fontSize: 12, color: AppColors.muted, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCardList extends StatelessWidget {
  final List<GroupStat> items;
  const _StatCardList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _StatEntryCard(key: ValueKey(item.id), stat: item);
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class _StatEntryCard extends StatelessWidget {
  final GroupStat stat;
  const _StatEntryCard({super.key, required this.stat});

  Color _rateColor(double p) {
    if (p >= 60) return const Color(0xFF16a34a);
    if (p >= 30) return const Color(0xFFd97706);
    return const Color(0xFFdc2626);
  }

  @override
  Widget build(BuildContext context) {
    final rateColor = _rateColor(stat.successRate);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.navy900)),
                const SizedBox(height: 6),
                Text('${stat.totalCases}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.navy900)),
                Text('hospitalManager.tickets'.tr, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(
                  '${'status.success'.tr}: ${stat.successCount} · ${'status.failed'.tr}: ${stat.failedCount}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: rateColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(
              '${stat.successRate.toStringAsFixed(0)}%',
              style: TextStyle(color: rateColor, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterChips extends GetView<HospitalManagerDashboardController> {
  final VoidCallback onCustomTap;
  const _QuickFilterChips({required this.onCustomTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final labels = {
        HmQuickFilter.thisMonth: 'hospitalManager.filterThisMonth'.tr,
        HmQuickFilter.lastMonth: 'hospitalManager.filterLastMonth'.tr,
        HmQuickFilter.allTime: 'hospitalManager.filterAllTime'.tr,
        HmQuickFilter.custom: 'hospitalManager.filterCustom'.tr,
      };
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: HmQuickFilter.values.map((f) {
          final selected = controller.quickFilter.value == f;
          return ChoiceChip(
            label: Text(labels[f]!),
            selected: selected,
            onSelected: (_) => f == HmQuickFilter.custom ? onCustomTap() : controller.applyQuickFilter(f),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.muted,
            ),
            backgroundColor: Colors.white,
            selectedColor: AppColors.blue500,
            side: BorderSide(color: selected ? AppColors.blue500 : AppColors.fieldBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          );
        }).toList(),
      );
    });
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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: color.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
