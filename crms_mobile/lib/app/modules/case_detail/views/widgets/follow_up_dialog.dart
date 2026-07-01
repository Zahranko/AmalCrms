import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../data/format.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/app_form_dropdown.dart';
import '../../../../widgets/app_text_field.dart';
import '../../controllers/case_detail_controller.dart';

/// Follow-up dialog.
/// - Pending / Failed: notes only (no date).
/// - Waiting: optional appointment date + department + optional doctor.
/// - Success: optional notes + optional عيادات (clinics) checkbox → doctor.
class FollowUpDialog extends StatefulWidget {
  final CaseDetailController controller;
  const FollowUpDialog({super.key, required this.controller});

  @override
  State<FollowUpDialog> createState() => _FollowUpDialogState();
}

class _FollowUpDialogState extends State<FollowUpDialog> {
  static const _statuses = ['Success', 'Waiting', 'Failed', 'Pending'];

  String _status = 'Success';

  // Waiting-only fields
  DateTime? _appointmentDate;
  int? _departmentId;
  bool _hasDoctor = false;
  int? _waitingDoctorId;

  // Success-only fields
  bool _clinics = false;
  int? _clinicsDoctorId;
  final _signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final _notesController = TextEditingController();
  bool _submitting = false;
  String? _error;

  bool get _isWaiting => _status == 'Waiting';
  bool get _isSuccess => _status == 'Success';

  @override
  void dispose() {
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _appointmentDate = picked);
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final notes = _notesController.text.trim();

    if (_isWaiting && _departmentId == null) {
      setState(() => _error = 'followUp.errorDepartment'.tr);
      return;
    }
    if (!_clinics && _status != 'Success' && notes.isEmpty) {
      setState(() => _error = 'followUp.errorNotes'.tr);
      return;
    }

    String? signatureData;
    if (_isSuccess && _clinics) {
      if (_signatureController.isEmpty) {
        setState(() => _error = 'followUp.signatureRequired'.tr);
        return;
      }
      final bytes = await _signatureController.toPngBytes();
      if (bytes == null) {
        setState(() => _error = 'followUp.signatureRequired'.tr);
        return;
      }
      signatureData = 'data:image/png;base64,${base64Encode(bytes)}';
    }

    final payload = {
      'status': _status,
      'date': _isWaiting && _appointmentDate != null ? toApiDate(_appointmentDate!) : null,
      'notes': (_isSuccess && _clinics) ? null : (notes.isEmpty ? null : notes),
      'departmentId': _isWaiting ? _departmentId : null,
      'hasDoctor': _isWaiting ? _hasDoctor : (_isSuccess ? _clinics : null),
      'doctorId': _isWaiting
          ? _waitingDoctorId
          : (_isSuccess && _clinics ? _clinicsDoctorId : null),
      'signatureData': signatureData,
    };

    setState(() => _submitting = true);
    final error = await widget.controller.followUp(payload);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'Success': return 'followUp.statusSuccess'.tr;
      case 'Waiting': return 'followUp.statusWaiting'.tr;
      case 'Failed':  return 'followUp.statusFailed'.tr;
      case 'Pending': return 'followUp.statusPending'.tr;
      default:        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctors = widget.controller.allDoctors;

    return AlertDialog(
      title: Text('followUp.title'.tr),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status picker
              AppFormDropdown<String>(
                label: 'followUp.newStatus'.tr,
                value: _status,
                hint: '',
                onChanged: (v) => setState(() {
                  _status = v ?? 'Success';
                  // Reset Waiting state when leaving Waiting
                  if (!_isWaiting) {
                    _departmentId = null;
                    _waitingDoctorId = null;
                    _hasDoctor = false;
                    _appointmentDate = null;
                  }
                  // Reset Success state when leaving Success
                  if (!_isSuccess) {
                    _clinics = false;
                    _clinicsDoctorId = null;
                  }
                }),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s))))
                    .toList(),
              ),

              // Waiting: optional appointment date + department + optional doctor
              if (_isWaiting) ...[
                const SizedBox(height: 14),
                _DateField(
                  label: 'followUp.appointmentDate'.tr,
                  value: _appointmentDate != null ? formatDate(_appointmentDate!) : '—',
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                AppFormDropdown<int>(
                  label: 'followUp.department'.tr,
                  value: _departmentId,
                  hint: 'followUp.selectDepartment'.tr,
                  onChanged: (v) => setState(() {
                    _departmentId = v;
                    _waitingDoctorId = null;
                  }),
                  items: widget.controller.departments
                      .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                ),
                const SizedBox(height: 6),
                CheckboxListTile(
                  value: _hasDoctor,
                  onChanged: (v) => setState(() => _hasDoctor = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  activeColor: AppColors.blue500,
                  title: Text('followUp.hasDoctor'.tr,
                      style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                ),
                if (_hasDoctor) ...[
                  AppFormDropdown<int>(
                    label: 'followUp.doctor'.tr,
                    value: _waitingDoctorId,
                    hint: 'followUp.selectDoctor'.tr,
                    onChanged: (v) => setState(() => _waitingDoctorId = v),
                    items: doctors
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                  ),
                ],
              ],

              // Success: clinics (عيادات) checkbox + signature pad (replaces notes) + optional doctor
              if (_isSuccess) ...[
                const SizedBox(height: 6),
                CheckboxListTile(
                  value: _clinics,
                  onChanged: (v) => setState(() {
                    _clinics = v ?? false;
                    if (!_clinics) {
                      _clinicsDoctorId = null;
                      _signatureController.clear();
                    }
                  }),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  activeColor: AppColors.blue500,
                  title: Text('followUp.clinics'.tr,
                      style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                ),
                if (_clinics) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${'followUp.signature'.tr} *',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fieldBorder, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Signature(
                        controller: _signatureController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _signatureController.clear()),
                      child: Text('action.cancel'.tr,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppFormDropdown<int>(
                    label: 'followUp.doctor'.tr,
                    value: _clinicsDoctorId,
                    hint: 'followUp.selectDoctor'.tr,
                    onChanged: (v) => setState(() => _clinicsDoctorId = v),
                    items: doctors
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                  ),
                ],
              ],

              if (!(_isSuccess && _clinics)) ...[
                const SizedBox(height: 14),
                AppTextField(
                  label: _isSuccess ? 'followUp.notesOptional'.tr : 'followUp.notes'.tr,
                  controller: _notesController,
                  maxLines: 3,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text('action.cancel'.tr),
        ),
        FilledButton(
          onPressed: _submitting ? null : _save,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text('action.save'.tr),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.fieldBorder, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Expanded(
                    child: Text(value,
                        style:
                            const TextStyle(fontSize: 14.5, color: AppColors.ink))),
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
