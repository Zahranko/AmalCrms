import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/case_status.dart';
import '../../../data/dial_codes.dart';
import '../../../data/format.dart';
import '../../../data/models/case_detail.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/error_banner.dart';
import '../controllers/case_detail_controller.dart';
import 'widgets/follow_up_dialog.dart';
import 'widgets/forward_dialog.dart';

class CaseDetailView extends GetView<CaseDetailController> {
  const CaseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppColors.navy900.withValues(alpha: 0.25),
        foregroundColor: AppColors.ink,
        title: Text('case.title'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.detail.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null && controller.detail.value == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ErrorBanner(controller.errorMessage.value!),
            );
          }
          final c = controller.detail.value;
          if (c == null) return const SizedBox.shrink();
          return _CaseBody(c: c);
        }),
      ),
    );
  }
}

class _CaseBody extends GetView<CaseDetailController> {
  final CaseDetail c;
  const _CaseBody({required this.c});

  @override
  Widget build(BuildContext context) {
    final meta = caseStatusMeta(c.status);

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: meta.background, borderRadius: BorderRadius.circular(999)),
                child: Text(meta.label, style: TextStyle(color: meta.color, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Actions(),
          const SizedBox(height: 16),
          _DetailCard(c: c),
          const SizedBox(height: 20),
          Text('case.timeline'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.navy900)),
          const SizedBox(height: 8),
          _Timeline(history: c.history),
        ],
      ),
    );
  }
}

class _Actions extends GetView<CaseDetailController> {
  static const _btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
  static const _btnPad = EdgeInsets.symmetric(horizontal: 18, vertical: 13);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.isForwarding.value || controller.isClaiming.value;
      final isAdmin = controller.authController.session.value?.role == 'Admin';
      final status = controller.detail.value?.status ?? '';
      final isReopenable = isAdmin && (status == 'Success' || status == 'Failed');
      final hasSecondary = controller.isPendingRecipient ||
          (!controller.isMine && !controller.isPendingRecipient) ||
          controller.canForward ||
          isReopenable;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary — Follow-up always shown full-width
          FilledButton.icon(
            onPressed: () => _openFollowUp(context),
            icon: const Icon(Icons.edit_note, size: 19),
            label: Text('action.followUp'.tr),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: _btnShape,
            ),
          ),
          // Secondary actions
          if (hasSecondary) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (controller.isPendingRecipient) ...[
                  FilledButton.icon(
                    onPressed: busy ? null : () => _acceptForward(context),
                    icon: busy
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline, size: 19),
                    label: Text('action.accept'.tr),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16a34a),
                      padding: _btnPad,
                      shape: _btnShape,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => _declineForward(context),
                    icon: const Icon(Icons.cancel_outlined, size: 19),
                    label: Text('action.decline'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFdc2626),
                      side: const BorderSide(color: Color(0xFFfca5a5)),
                      padding: _btnPad,
                      shape: _btnShape,
                    ),
                  ),
                ],
                if (!controller.isMine && !controller.isPendingRecipient)
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => _claim(context),
                    icon: busy
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.assignment_ind_outlined, size: 19),
                    label: Text('action.assignToMe'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy700,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      padding: _btnPad,
                      shape: _btnShape,
                    ),
                  ),
                if (controller.canForward)
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => _openForward(context),
                    icon: const Icon(Icons.forward_to_inbox_outlined, size: 19),
                    label: Text('action.forward'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy700,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      padding: _btnPad,
                      shape: _btnShape,
                    ),
                  ),
                if (isReopenable)
                  FilledButton.icon(
                    onPressed: busy ? null : () => _reopen(context),
                    icon: const Icon(Icons.refresh, size: 19),
                    label: Text('action.reopen'.tr),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy700,
                      padding: _btnPad,
                      shape: _btnShape,
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Future<void> _claim(BuildContext context) async {
    final error = await controller.claim();
    if (error != null) {
      Get.snackbar('case.couldNotAssign'.tr, error,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }

  Future<void> _acceptForward(BuildContext context) async {
    final error = await controller.acceptForward();
    if (error != null && context.mounted) {
      Get.snackbar('case.couldNotAccept'.tr, error,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }

  Future<void> _declineForward(BuildContext context) async {
    final error = await controller.declineForward();
    if (error != null && context.mounted) {
      Get.snackbar('case.couldNotDecline'.tr, error,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }

  Future<void> _openForward(BuildContext context) async {
    try {
      await controller.ensureUsers();
    } catch (_) {}
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => ForwardDialog(controller: controller),
    );
  }

  Future<void> _reopen(BuildContext context) async {
    final error = await controller.reopen();
    if (error != null && context.mounted) {
      Get.snackbar('case.couldNotReopen'.tr, error,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: AppColors.ink);
    }
  }

  Future<void> _openFollowUp(BuildContext context) async {
    try {
      await controller.ensureLookups();
    } catch (_) {}
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => FollowUpDialog(controller: controller),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final CaseDetail c;
  const _DetailCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[];

    void add(String label, String? value) {
      if (value != null && value.isNotEmpty) rows.add([label, value]);
    }

    add('case.phone'.tr, formatPhone(c.phoneCountryCode, c.phoneNumber));
    add('case.referralSource'.tr, c.referralSource);
    add('case.procedure'.tr, c.procedure);
    add('case.department'.tr, c.department);
    rows.add(['case.hasDoctor'.tr, c.hasDoctor ? 'case.yes'.tr : 'case.no'.tr]);
    add('case.doctor'.tr, c.doctor);
    if (c.appointmentDate != null) rows.add(['case.appointment'.tr, formatDate(c.appointmentDate!)]);
    add('case.createdBy'.tr, c.createdByUsername);
    rows.add(['case.assignedTo'.tr,
      (c.assignedToUsername == null || c.assignedToUsername!.isEmpty)
          ? 'case.unassigned'.tr
          : c.assignedToUsername!]);
    if (c.forwardedToUsername != null) rows.add(['case.pendingForwardTo'.tr, c.forwardedToUsername!]);
    rows.add(['case.created'.tr, formatDateTime(c.createdAt)]);

    return Column(
      children: [
        for (final r in rows) _DetailRow(label: r[0], value: r[1]),
        if (c.description.isNotEmpty)
          _DetailRow(label: 'case.description'.tr, value: c.description, multiline: true),
        if (c.clinicSignature != null) _DetailSignature(dataUrl: c.clinicSignature!),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiline;
  const _DetailRow({required this.label, required this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.blue500, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.blue500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _DetailSignature extends StatelessWidget {
  final String dataUrl;
  const _DetailSignature({required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(dataUrl.split(',').last);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppColors.blue500, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'case.signature'.tr.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.blue500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<CaseAction> history;
  const _Timeline({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('case.noHistory'.tr, style: const TextStyle(color: AppColors.muted)),
      );
    }
    return Column(children: history.map((a) => _TimelineItem(a: a)).toList());
  }
}

class _TimelineItem extends StatelessWidget {
  final CaseAction a;
  const _TimelineItem({required this.a});

  String get _title {
    final actor = a.actorUsername ?? 'Someone';
    switch (a.type) {
      case 'Created':
        return 'timeline.created'.trParams({'actor': actor});
      case 'Forwarded':
        return 'timeline.forwarded'.trParams({'actor': actor, 'target': a.targetUsername ?? ''});
      case 'ForwardAccepted':
        return 'timeline.forwardAccepted'.trParams({'actor': actor});
      case 'ForwardDeclined':
        return 'timeline.forwardDeclined'.trParams({'actor': actor});
      case 'Claimed':
        return 'timeline.claimed'.trParams({'actor': actor});
      case 'Reopened':
        return 'timeline.reopened'.trParams({'actor': actor});
      default:
        final meta = caseStatusMeta(a.resultingStatus ?? '');
        return 'timeline.followUp'.trParams({'actor': actor, 'status': meta.label});
    }
  }

  @override
  Widget build(BuildContext context) {
    final metaBits = <String>[];
    if (a.departmentName != null) metaBits.add('timeline.dept'.trParams({'name': a.departmentName!}));
    if (a.doctorName != null) metaBits.add('timeline.doctor'.trParams({'name': a.doctorName!}));
    if (a.actionDate != null) metaBits.add('timeline.date'.trParams({'date': formatDate(a.actionDate!)}));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
          if (metaBits.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(metaBits.join(' · '), style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
          ],
          if (a.note != null && a.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(a.note!, style: const TextStyle(fontSize: 13.5, color: AppColors.ink)),
          ],
          const SizedBox(height: 6),
          Text(formatDateTime(a.createdAt), style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}
