import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_banner.dart';
import '../../../widgets/status_pill.dart';
import '../controllers/manage_lists_controller.dart';
import 'widgets/list_item_form_dialog.dart';

/// Mirrors manageLists.html — a tabbed admin manager for the four lookup lists.
class ManageListsView extends GetView<ManageListsController> {
  const ManageListsView({super.key});

  Map<ListTab, String> get _tabLabels => {
        ListTab.department: 'manageLists.departments'.tr,
        ListTab.referral: 'manageLists.referralSources'.tr,
        ListTab.procedure: 'manageLists.procedures'.tr,
        ListTab.doctor: 'manageLists.doctors'.tr,
      };

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        backgroundColor: AppColors.blue500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('manageLists.addItem'.tr),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('manageLists.title'.tr,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900)),
                const SizedBox(height: 12),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ListTab.values.map((t) {
                      final selected = controller.tab.value == t;
                      return ChoiceChip(
                        label: Text(_tabLabels[t]!),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) => controller.tab.value = t,
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
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadAll,
              child: Obx(() {
                if (controller.isLoading.value && controller.departments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    if (controller.errorMessage.value != null) ErrorBanner(controller.errorMessage.value!),
                    ..._buildRows(context),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    switch (controller.tab.value) {
      case ListTab.department:
        if (controller.departments.isEmpty) return [_empty('manageLists.empty.departments'.tr)];
        return controller.departments
            .map((d) => _Card(
                  name: d.name,
                  isActive: d.isActive,
                  onEdit: () => showListItemFormDialog(
                    context,
                    title: 'manageLists.editDept'.tr,
                    initialName: d.name,
                    onSubmit: (name) => controller.updateDepartment(d.id, name),
                  ),
                  onToggle: () => _toggle(context, d.name, d.isActive,
                      (next) => controller.setDepartmentStatus(d, next)),
                ))
            .toList();
      case ListTab.referral:
        if (controller.referralSources.isEmpty) return [_empty('manageLists.empty.referralSources'.tr)];
        return controller.referralSources
            .map((r) => _Card(
                  name: r.name,
                  isActive: r.isActive,
                  onEdit: () => showListItemFormDialog(
                    context,
                    title: 'manageLists.editRef'.tr,
                    initialName: r.name,
                    onSubmit: (name) => controller.updateReferralSource(r.id, name),
                  ),
                  onToggle: () => _toggle(context, r.name, r.isActive,
                      (next) => controller.setReferralSourceStatus(r, next)),
                ))
            .toList();
      case ListTab.procedure:
        if (controller.procedures.isEmpty) return [_empty('manageLists.empty.procedures'.tr)];
        return controller.procedures
            .map((p) => _Card(
                  name: p.name,
                  isActive: p.isActive,
                  onEdit: () => showListItemFormDialog(
                    context,
                    title: 'manageLists.editProc'.tr,
                    initialName: p.name,
                    onSubmit: (name) => controller.updateProcedure(p.id, name),
                  ),
                  onToggle: () => _toggle(context, p.name, p.isActive,
                      (next) => controller.setProcedureStatus(p, next)),
                ))
            .toList();
      case ListTab.doctor:
        if (controller.doctors.isEmpty) return [_empty('manageLists.empty.doctors'.tr)];
        return controller.doctors
            .map((doc) => _Card(
                  name: doc.name,
                  isActive: doc.isActive,
                  onEdit: () => showListItemFormDialog(
                    context,
                    title: 'manageLists.editDoctor'.tr,
                    initialName: doc.name,
                    onSubmit: (name) => controller.updateDoctor(doc.id, name),
                  ),
                  onToggle: () => _toggle(context, doc.name, doc.isActive,
                      (next) => controller.setDoctorStatus(doc, next)),
                ))
            .toList();
    }
  }

  Widget _empty(String label) => EmptyState(icon: Icons.list_alt_outlined, title: label);

  void _add(BuildContext context) {
    switch (controller.tab.value) {
      case ListTab.department:
        showListItemFormDialog(
          context,
          title: 'manageLists.addDept'.tr,
          onSubmit: (name) => controller.createDepartment(name),
        );
        break;
      case ListTab.referral:
        showListItemFormDialog(
          context,
          title: 'manageLists.addRef'.tr,
          onSubmit: (name) => controller.createReferralSource(name),
        );
        break;
      case ListTab.procedure:
        showListItemFormDialog(
          context,
          title: 'manageLists.addProc'.tr,
          onSubmit: (name) => controller.createProcedure(name),
        );
        break;
      case ListTab.doctor:
        showListItemFormDialog(
          context,
          title: 'manageLists.addDoctor'.tr,
          onSubmit: (name) => controller.createDoctor(name),
        );
        break;
    }
  }

  Future<void> _toggle(
    BuildContext context,
    String name,
    bool isActive,
    Future<String?> Function(bool next) onConfirmed,
  ) async {
    final next = !isActive;
    final confirmed = await showConfirmDialog(
      context,
      title: next ? 'action.enable'.tr : 'action.disable'.tr,
      message: next
          ? 'confirm.enableMsg'.trParams({'name': name})
          : 'confirm.disableMsg'.trParams({'name': name}),
      confirmLabel: next ? 'action.enable'.tr : 'action.disable'.tr,
      danger: !next,
    );
    if (!confirmed) return;
    final error = await onConfirmed(next);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _Card extends StatelessWidget {
  final String name;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _Card({
    required this.name,
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
          children: [
            Expanded(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.ink, fontSize: 14)),
            ),
            StatusPill(isActive: isActive),
            IconButton(
              tooltip: 'action.edit'.tr,
              icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.muted),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: isActive ? 'action.disable'.tr : 'action.enable'.tr,
              icon: Icon(isActive ? Icons.block : Icons.check_circle_outline,
                  size: 19, color: isActive ? AppColors.error : AppColors.blue500),
              onPressed: onToggle,
            ),
        ],
      ),
    );
  }
}
