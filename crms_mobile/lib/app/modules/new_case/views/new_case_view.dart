import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/dial_codes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_form_dropdown.dart';
import '../../../widgets/app_shell_scaffold.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/error_banner.dart';
import '../controllers/new_case_controller.dart';

class NewCaseView extends GetView<NewCaseController> {
  const NewCaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellScaffold(
      body: Obx(() {
        if (controller.isLoadingLookups.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'newCase.title'.tr,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.navy900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'newCase.subtitle'.tr,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  if (controller.errorMessage.value != null)
                    ErrorBanner(controller.errorMessage.value!),
                  AppTextField(label: 'newCase.patientName'.tr, controller: controller.nameController),
                  const SizedBox(height: 16),
                  _PhoneField(),
                  const SizedBox(height: 16),
                  AppFormDropdown<int>(
                    label: 'newCase.referralSource'.tr,
                    value: controller.referralSourceId.value,
                    hint: 'newCase.selectOption'.tr,
                    onChanged: (v) => controller.referralSourceId.value = v,
                    items: controller.referralSources
                        .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AppFormDropdown<int>(
                    label: 'newCase.department'.tr,
                    value: controller.departmentId.value,
                    hint: 'newCase.selectDepartment'.tr,
                    onChanged: (v) => controller.departmentId.value = v,
                    items: controller.departments
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AppFormDropdown<int>(
                    label: 'newCase.procedure'.tr,
                    value: controller.procedureId.value,
                    hint: 'newCase.selectProcedure'.tr,
                    onChanged: (v) => controller.procedureId.value = v,
                    items: controller.procedures
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _HasDoctorCheck(),
                  const SizedBox(height: 8),
                  AppFormDropdown<int>(
                    label: 'newCase.doctor'.tr,
                    value: controller.doctorId.value,
                    hint: 'newCase.selectDoctor'.tr,
                    onChanged: (v) => controller.doctorId.value = v,
                    items: controller.doctors
                        .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'newCase.description'.tr,
                    controller: controller.descriptionController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: controller.isSubmitting.value ? null : controller.submit,
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('newCase.createCase'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PhoneField extends GetView<NewCaseController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('newCase.phone'.tr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
        const SizedBox(height: 8),
        Row(
          children: [
            Obx(
              () => Container(
                width: 110,
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.fieldBorder, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.dialCode.value,
                    isExpanded: true,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                    style: const TextStyle(fontSize: 14, color: AppColors.ink, fontFamily: 'Poppins'),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    items: kDialCodes
                        .map((c) => DropdownMenuItem(
                              value: c.dialCode,
                              child: Text('${c.dialCode}  ${c.iso}', overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) controller.dialCode.value = v;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.fieldBorder, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
                  style: const TextStyle(fontSize: 14.5, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'newCase.phone'.tr,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HasDoctorCheck extends GetView<NewCaseController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CheckboxListTile(
        value: controller.hasDoctor.value,
        onChanged: (v) => controller.hasDoctor.value = v ?? false,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
        activeColor: AppColors.blue500,
        title: Text('newCase.hasDoctor'.tr, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
      ),
    );
  }
}
