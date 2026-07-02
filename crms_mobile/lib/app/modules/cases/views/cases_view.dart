import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/case_status.dart';
import '../../../data/dial_codes.dart';
import '../../../data/models/case_summary.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_banner.dart';
import '../controllers/cases_controller.dart';

/// The cases hub. Mirrors the employee dashboard: filterable, searchable list
/// of every case with a quick "Assign to me" action and tap-through to detail.
class CasesView extends GetView<CasesController> {
  const CasesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.newCase),
        backgroundColor: AppColors.blue500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('cases.newCase'.tr),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dashboard.title'.tr,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                ),
                const SizedBox(height: 12),
                _FilterChips(),
                const SizedBox(height: 12),
                _SearchField(),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadCases,
              child: Obx(() {
                if (controller.isLoading.value && controller.allCases.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cases = controller.visibleCases;
                final hasError = controller.errorMessage.value != null;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: (hasError ? 1 : 0) + (cases.isEmpty ? 1 : cases.length),
                  itemBuilder: (context, index) {
                    if (hasError && index == 0) {
                      return ErrorBanner(controller.errorMessage.value!);
                    }
                    final i = hasError ? index - 1 : index;
                    if (cases.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'cases.noResults'.tr,
                        hint: 'empty.pullToRefresh'.tr,
                      );
                    }
                    final c = cases[i];
                    return _CaseCard(key: ValueKey(c.id), caseItem: c);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends GetView<CasesController> {
  @override
  Widget build(BuildContext context) {
    final labels = {
      CaseFilter.all: 'filter.allCases'.tr,
      CaseFilter.today: 'filter.today'.tr,
      CaseFilter.mine: 'filter.assignedToMe'.tr,
      CaseFilter.unassigned: 'filter.unassigned'.tr,
    };

    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CaseFilter.values.map((f) {
          final selected = controller.filter.value == f;
          return ChoiceChip(
            label: Text(labels[f]!),
            selected: selected,
            onSelected: (_) => controller.filter.value = f,
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
      ),
    );
  }
}

class _SearchField extends GetView<CasesController> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (v) => controller.search.value = v,
      style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: 'search.placeholder'.tr,
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue500, width: 1.5),
        ),
      ),
    );
  }
}

class _CaseCard extends GetView<CasesController> {
  final CaseSummary caseItem;
  const _CaseCard({super.key, required this.caseItem});

  @override
  Widget build(BuildContext context) {
    final meta = caseStatusMeta(caseItem.status);
    final assigned = caseItem.assignedToUsername;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Get.toNamed(Routes.caseDetail, arguments: caseItem.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: status-tinted initials avatar, name + phone, status pill(s).
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                _Avatar(name: caseItem.name, color: meta.color, background: meta.background),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseItem.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.navy900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatPhone(caseItem.phoneCountryCode, caseItem.phoneNumber),
                        style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Pill(label: meta.label, color: meta.color, background: meta.background),
                    if (caseItem.forwardedByUsername != null) ...[
                      const SizedBox(height: 4),
                      _Pill(
                        label: 'badge.forwarded'.tr,
                        color: const Color(0xFF6D28D9),
                        background: const Color(0xFFEDE9FE),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          // Metadata
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caseItem.procedure != null && caseItem.procedure!.isNotEmpty)
                  _InfoRow(icon: Icons.medical_services_outlined, text: caseItem.procedure!),
                _InfoRow(icon: Icons.local_hospital_outlined, text: caseItem.department ?? '—'),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  text: '${'case.createdBy'.tr} ${caseItem.createdByUsername ?? '—'}',
                ),
                _InfoRow(
                  icon: Icons.assignment_ind_outlined,
                  text: assigned == null || assigned.isEmpty
                      ? 'case.unassigned'.tr
                      : '${'case.assignedTo'.tr} $assigned',
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 10, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => Get.toNamed(Routes.caseDetail, arguments: caseItem.id),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: Text('action.view'.tr),
                ),
                const Spacer(),
                if (!controller.isMine(caseItem))
                  Obx(() {
                    final busy = controller.claimingId.value == caseItem.id;
                    return FilledButton(
                      onPressed: busy ? null : () => _claim(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('action.assignToMe'.tr),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final error = await controller.claim(caseItem);
    if (error != null) {
      Get.snackbar('cases.couldNotAssign'.tr, error,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }
}

/// Circular initials avatar tinted with the case's status colour.
class _Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final Color background;
  const _Avatar({required this.name, required this.color, required this.background});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '؟';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(_initials, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14.5)),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _Pill({required this.label, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
