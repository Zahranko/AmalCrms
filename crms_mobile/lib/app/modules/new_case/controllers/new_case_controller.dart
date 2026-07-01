import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/dial_codes.dart';
import '../../../data/models/department.dart';
import '../../../data/models/doctor.dart';
import '../../../data/models/procedure.dart';
import '../../../data/models/referral_source.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_routes.dart';

class NewCaseController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final descriptionController = TextEditingController();

  final RxString dialCode = kDefaultDialCode.obs;
  final RxnInt referralSourceId = RxnInt();
  final RxnInt departmentId = RxnInt();
  final RxnInt procedureId = RxnInt();
  final RxBool hasDoctor = false.obs;
  final RxnInt doctorId = RxnInt();

  final RxList<ReferralSource> referralSources = <ReferralSource>[].obs;
  final RxList<Department> departments = <Department>[].obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxList<Procedure> procedures = <Procedure>[].obs;

  final RxBool isLoadingLookups = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString errorMessage = RxnString();

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> _loadLookups() async {
    isLoadingLookups.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _apiService.getReferralSources(_token),
        _apiService.getDepartments(_token),
        _apiService.getDoctors(_token),
        _apiService.getProcedures(_token),
      ]);
      referralSources.assignAll(results[0] as List<ReferralSource>);
      departments.assignAll(results[1] as List<Department>);
      doctors.assignAll(results[2] as List<Doctor>);
      procedures.assignAll(results[3] as List<Procedure>);
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return;
      }
      errorMessage.value = e.toString();
    } finally {
      isLoadingLookups.value = false;
    }
  }

  Future<void> submit() async {
    errorMessage.value = null;

    if (nameController.text.trim().length < 2) {
      errorMessage.value = 'newCase.errorName'.tr;
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      errorMessage.value = 'newCase.errorPhone'.tr;
      return;
    }
    if (referralSourceId.value == null) {
      errorMessage.value = 'newCase.errorReferral'.tr;
      return;
    }
    if (departmentId.value == null) {
      errorMessage.value = 'newCase.errorDepartment'.tr;
      return;
    }
    if (procedureId.value == null) {
      errorMessage.value = 'newCase.errorProcedure'.tr;
      return;
    }
    if (descriptionController.text.trim().length < 2) {
      errorMessage.value = 'newCase.errorDescription'.tr;
      return;
    }

    final payload = {
      'name': nameController.text.trim(),
      'phoneCountryCode': dialCode.value,
      'phoneNumber': phoneController.text.trim(),
      'referralSourceId': referralSourceId.value,
      'departmentId': departmentId.value,
      'procedureId': procedureId.value,
      'hasDoctor': hasDoctor.value,
      'doctorId': doctorId.value,
      'description': descriptionController.text.trim(),
    };

    isSubmitting.value = true;
    try {
      final created = await _apiService.createCase(_token, payload);
      Get.offNamed(Routes.caseDetail, arguments: created.id);
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return;
      }
      errorMessage.value = e.toString();
    } finally {
      isSubmitting.value = false;
    }
  }
}
