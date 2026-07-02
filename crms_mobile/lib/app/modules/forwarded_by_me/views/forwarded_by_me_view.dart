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
import '../controllers/forwarded_by_me_controller.dart';

class ForwardedByMeView extends GetView<ForwardedByMeController> {
  const ForwardedByMeView({super.key});

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
                  'forwardedOut.title'.tr,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                ),
                const SizedBox(height: 4),
                Text(
                  'forwardedOut.subtitle'.tr,
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
                        icon: Icons.outbox_outlined,
                        title: 'forwardedOut.empty'.tr,
                        hint: 'empty.pullToRefresh'.tr,
                      );
                    }
                    final c = cases[i];
                    return _CaseCard(key: ValueKey(c.id), c: c);
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

class _CaseCard extends StatelessWidget {
  final CaseSummary c;
  const _CaseCard({super.key, required this.c});

  // Pending outgoing: I still own it (assignedToUsername = me) and forwardedToUsername is set
  bool get isPending => c.forwardedToUsername != null;

  @override
  Widget build(BuildContext context) {
    final meta = caseStatusMeta(c.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        title: Row(
          children: [
            Expanded(
              child: Text(
                c.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.navy900),
              ),
            ),
            const SizedBox(width: 8),
            if (isPending)
              _StatusBadge(label: 'badge.pending'.tr, color: const Color(0xFF9A6A00), bg: const Color(0xFFFFF3D6))
            else
              _StatusBadge(label: 'badge.transferred'.tr, color: const Color(0xFF6D28D9), bg: const Color(0xFFEDE9FE)),
            const SizedBox(width: 6),
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
              const SizedBox(height: 2),
              if (isPending)
                Text('${'badge.awaitingUser'.tr} ${c.forwardedToUsername}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted))
              else
                Text('${'badge.nowWith'.tr} ${c.assignedToUsername ?? '—'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ],
          ),
        ),
        onTap: () => Get.toNamed(Routes.caseDetail, arguments: c.id),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _StatusBadge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11.5)),
    );
  }
}
