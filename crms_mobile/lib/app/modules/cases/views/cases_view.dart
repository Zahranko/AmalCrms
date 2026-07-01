import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/case_status.dart';
import '../../../data/dial_codes.dart';
import '../../../data/models/case_summary.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_shell_scaffold.dart';
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

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    if (controller.errorMessage.value != null)
                      ErrorBanner(controller.errorMessage.value!),
                    if (cases.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text('cases.noResults'.tr, style: const TextStyle(color: AppColors.muted)),
                        ),
                      )
                    else
                      ...cases.map((c) => _CaseCard(caseItem: c)),
                  ],
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
  const _CaseCard({required this.caseItem});

  @override
  Widget build(BuildContext context) {
    final meta = caseStatusMeta(caseItem.status);
    final assigned = caseItem.assignedToUsername;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.toNamed(Routes.caseDetail, arguments: caseItem.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      caseItem.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (caseItem.forwardedByUsername != null) ...[
                    _Pill(
                      label: 'badge.forwarded'.tr,
                      color: const Color(0xFF6D28D9),
                      background: const Color(0xFFEDE9FE),
                    ),
                    const SizedBox(width: 6),
                  ],
                  _Pill(label: meta.label, color: meta.color, background: meta.background),
                ],
              ),
              const SizedBox(height: 8),
              if (caseItem.procedure != null && caseItem.procedure!.isNotEmpty)
                _ProcedureLabel(caseItem.procedure!),
              const SizedBox(height: 6),
              _InfoRow(icon: Icons.phone_outlined, text: formatPhone(caseItem.phoneCountryCode, caseItem.phoneNumber)),
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
              const SizedBox(height: 10),
              Row(
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
            ],
          ),
        ),
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

class _ProcedureLabel extends StatelessWidget {
  final String text;
  const _ProcedureLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF1A56DB), fontSize: 12, fontWeight: FontWeight.w500),
      ),
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
