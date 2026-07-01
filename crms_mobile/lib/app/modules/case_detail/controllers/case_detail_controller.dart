import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/case_detail.dart';
import '../../../data/models/department.dart';
import '../../../data/models/doctor.dart';
import '../../../data/services/api_service.dart';

class CaseDetailController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final int caseId;
  CaseDetailController(this.caseId);

  final Rxn<CaseDetail> detail = Rxn<CaseDetail>();
  final RxBool isLoading = false.obs;
  final RxBool isClaiming = false.obs;
  final RxBool isForwarding = false.obs;
  final RxnString errorMessage = RxnString();

  final RxList<Department> departments = <Department>[].obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxList<AppUser> forwardableUsers = <AppUser>[].obs;
  bool _lookupsLoaded = false;
  bool _usersLoaded = false;

  String get _token => authController.session.value!.token;
  String get username => authController.session.value!.username;

  bool get isMine => detail.value?.assignedToUsername == username;
  bool get isPendingRecipient => detail.value?.forwardedToUsername == username;
  bool get canForward => isMine && detail.value?.forwardedToUsername == null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      detail.value = await _apiService.getCaseDetail(_token, caseId);
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return;
      }
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ensureLookups() async {
    if (_lookupsLoaded) return;
    final results = await Future.wait([
      _apiService.getDepartments(_token),
      _apiService.getDoctors(_token),
    ]);
    departments.assignAll(results[0] as List<Department>);
    doctors.assignAll(results[1] as List<Doctor>);
    _lookupsLoaded = true;
  }

  Future<void> ensureUsers() async {
    if (_usersLoaded) return;
    final users = await _apiService.getUsers(_token);
    forwardableUsers.assignAll(users.where((u) => u.isActive && u.username != username).toList());
    _usersLoaded = true;
  }

  List<Doctor> get allDoctors => doctors.toList();

  Future<String?> claim() async {
    isClaiming.value = true;
    try {
      detail.value = await _apiService.claimCase(_token, caseId);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    } finally {
      isClaiming.value = false;
    }
  }

  Future<String?> forward(int toUserId, String? note) async {
    isForwarding.value = true;
    try {
      detail.value = await _apiService.forwardCase(_token, caseId, toUserId, note);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    } finally {
      isForwarding.value = false;
    }
  }

  Future<String?> acceptForward() async {
    isForwarding.value = true;
    try {
      detail.value = await _apiService.acceptForward(_token, caseId);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    } finally {
      isForwarding.value = false;
    }
  }

  Future<String?> declineForward() async {
    isForwarding.value = true;
    try {
      detail.value = await _apiService.declineForward(_token, caseId);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    } finally {
      isForwarding.value = false;
    }
  }

  Future<String?> reopen() async {
    try {
      detail.value = await _apiService.reopenCase(_token, caseId);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    }
  }

  Future<String?> followUp(Map<String, dynamic> payload) async {
    try {
      detail.value = await _apiService.followUpCase(_token, caseId, payload);
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    }
  }
}
