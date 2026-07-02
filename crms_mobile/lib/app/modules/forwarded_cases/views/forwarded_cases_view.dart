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
import '../controllers/forwarded_cases_controller.dart';

class ForwardedCasesView extends GetView<ForwardedCasesController> {
  const ForwardedCasesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'forwardedIn.title'.tr,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                ),
                const SizedBox(height: 4),
                Text(
                  'forwardedIn.subtitle'.tr,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(() {
                if (controller.isLoading.value && controller.cases.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cases = controller.cases;
                final hasError = controller.errorMessage.value != null;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: (hasError ? 1 : 0) + (cases.isEmpty ? 1 : cases.length),
                  itemBuilder: (context, index) {
                    if (hasError && index == 0) {
                      return ErrorBanner(controller.errorMessage.value!);
                    }
                    final i = hasError ? index - 1 : index;
                    if (cases.isEmpty) {
                      return EmptyState(
                        icon: Icons.move_to_inbox_outlined,
                        title: 'forwardedIn.empty'.tr,
                        hint: 'empty.pullToRefresh'.tr,
                      );
                    }
                    final c = cases[i];
                    return _ForwardedCaseCard(key: ValueKey(c.id), c: c);
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

class _ForwardedCaseCard extends GetView<ForwardedCasesController> {
  final CaseSummary c;
  const _ForwardedCaseCard({super.key, required this.c});

  // Pending = a forward is waiting for my action (I haven't accepted yet)
  bool get isPending => c.hasPendingForward;

  // Re-forward = case was originally mine, was forwarded out, worked on, and forwarded back
  bool get isReforward {
    final me = controller.authController.session.value?.username;
    return isPending && c.forwardedByUsername == me;
  }

  @override
  Widget build(BuildContext context) {
    final meta = caseStatusMeta(c.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    c.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.navy900),
                  ),
                ),
                const SizedBox(width: 8),
                // Pending normal forward: show "Forwarded" badge
                // Pending re-forward (was originally mine): show just the status below
                // Accepted: show "Accepted" badge
                if (isPending && !isReforward)
                  _Badge(label: 'badge.forwarded'.tr, color: const Color(0xFF1D4ED8), bg: const Color(0xFFEFF6FF)),
                if (!isPending) ...[
                  _Badge(label: 'badge.accepted'.tr, color: const Color(0xFF1B7A43), bg: const Color(0xFFDDF3E4)),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: meta.background, borderRadius: BorderRadius.circular(999)),
                  child: Text(meta.label, style: TextStyle(color: meta.color, fontWeight: FontWeight.w600, fontSize: 11.5)),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPhone(c.phoneCountryCode, c.phoneNumber),
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                  if (c.department != null) ...[
                    const SizedBox(height: 2),
                    Text(c.department!, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  ],
                  if (isPending && !isReforward && c.assignedToUsername != null) ...[
                    const SizedBox(height: 2),
                    Text('${'badge.from'.tr} ${c.assignedToUsername}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                  if (isPending && isReforward && c.assignedToUsername != null) ...[
                    const SizedBox(height: 2),
                    Text('${'badge.nowWith'.tr} ${c.assignedToUsername}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                  if (!isPending && c.forwardedByUsername != null) ...[
                    const SizedBox(height: 2),
                    Text('${'badge.forwardedBy'.tr} ${c.forwardedByUsername}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            onTap: () => Get.toNamed(Routes.caseDetail, arguments: c.id),
          ),
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Obx(() {
                final isProcessing = controller.processingId.value == c.id;
                return Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: isProcessing ? null : () => _accept(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF16a34a),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isProcessing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('action.accept'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : () => _decline(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFdc2626),
                          side: const BorderSide(color: Color(0xFFfca5a5)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('action.decline'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final err = await controller.accept(c.id);
    if (err != null && context.mounted) {
      Get.snackbar('forwardedIn.couldNotAccept'.tr, err,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    } else {
      Get.toNamed(Routes.caseDetail, arguments: c.id);
    }
  }

  Future<void> _decline(BuildContext context) async {
    final err = await controller.decline(c.id);
    if (err != null && context.mounted) {
      Get.snackbar('forwardedIn.couldNotDecline'.tr, err,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Badge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11.5)),
    );
  }
}
