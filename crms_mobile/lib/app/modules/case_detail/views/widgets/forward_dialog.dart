import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/app_user.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_form_dropdown.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/case_detail_controller.dart';

class ForwardDialog extends StatefulWidget {
  final CaseDetailController controller;
  const ForwardDialog({super.key, required this.controller});

  @override
  State<ForwardDialog> createState() => _ForwardDialogState();
}

class _ForwardDialogState extends State<ForwardDialog> {
  AppUser? _selectedUser;
  final _noteCtrl = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedUser == null) {
      setState(() => _error = 'forward.errorColleague'.tr);
      return;
    }
    setState(() { _error = null; _submitting = true; });
    final err = await widget.controller.forward(_selectedUser!.id, _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim());
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _submitting = false; });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.controller.forwardableUsers;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('forward.title'.tr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.navy900)),
            const SizedBox(height: 16),
            AppFormDropdown<AppUser>(
              label: 'forward.forwardTo'.tr,
              value: _selectedUser,
              hint: 'forward.selectColleague'.tr,
              items: users.map((u) => DropdownMenuItem(value: u, child: Text(u.username))).toList(),
              onChanged: (v) => setState(() => _selectedUser = v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'forward.note'.tr,
              controller: _noteCtrl,
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.fieldBorder),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('action.cancel'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue500,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('action.forward'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
