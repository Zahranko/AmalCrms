import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/department.dart';
import '../../../data/models/doctor.dart';
import '../../../data/models/procedure.dart';
import '../../../data/models/referral_source.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_routes.dart';

enum ListTab { department, referral, procedure, doctor }

class ManageListsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final Rx<ListTab> tab = ListTab.department.obs;

  final RxList<Department> departments = <Department>[].obs;
  final RxList<ReferralSource> referralSources = <ReferralSource>[].obs;
  final RxList<Procedure> procedures = <Procedure>[].obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    if (authController.session.value?.role != 'Admin') {
      Future.microtask(() => Get.offNamed(Routes.dashboard));
      return;
    }
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _apiService.getDepartmentsManage(_token),
        _apiService.getReferralSourcesManage(_token),
        _apiService.getProceduresManage(_token),
        _apiService.getDoctorsManage(_token),
      ]);
      departments.assignAll(results[0] as List<Department>);
      referralSources.assignAll(results[1] as List<ReferralSource>);
      procedures.assignAll(results[2] as List<Procedure>);
      doctors.assignAll(results[3] as List<Doctor>);
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

  // ---------- Departments ----------

  Future<String?> createDepartment(String name) => _run(() async {
        departments.add(await _apiService.createDepartment(_token, name));
      });

  Future<String?> updateDepartment(int id, String name) => _run(() async {
        final updated = await _apiService.updateDepartment(_token, id, name);
        final i = departments.indexWhere((d) => d.id == id);
        if (i != -1) departments[i] = updated;
      });

  Future<String?> setDepartmentStatus(Department d, bool isActive) => _run(() async {
        await _apiService.setDepartmentStatus(_token, d.id, isActive);
        final i = departments.indexWhere((x) => x.id == d.id);
        if (i != -1) departments[i] = Department(id: d.id, name: d.name, isActive: isActive);
      });

  // ---------- Referral sources ----------

  Future<String?> createReferralSource(String name) => _run(() async {
        referralSources.add(await _apiService.createReferralSource(_token, name));
      });

  Future<String?> updateReferralSource(int id, String name) => _run(() async {
        final updated = await _apiService.updateReferralSource(_token, id, name);
        final i = referralSources.indexWhere((r) => r.id == id);
        if (i != -1) referralSources[i] = updated;
      });

  Future<String?> setReferralSourceStatus(ReferralSource r, bool isActive) => _run(() async {
        await _apiService.setReferralSourceStatus(_token, r.id, isActive);
        final i = referralSources.indexWhere((x) => x.id == r.id);
        if (i != -1) referralSources[i] = ReferralSource(id: r.id, name: r.name, isActive: isActive);
      });

  // ---------- Procedures ----------

  Future<String?> createProcedure(String name) => _run(() async {
        procedures.add(await _apiService.createProcedure(_token, name));
      });

  Future<String?> updateProcedure(int id, String name) => _run(() async {
        final updated = await _apiService.updateProcedure(_token, id, name);
        final i = procedures.indexWhere((p) => p.id == id);
        if (i != -1) procedures[i] = updated;
      });

  Future<String?> setProcedureStatus(Procedure p, bool isActive) => _run(() async {
        await _apiService.setProcedureStatus(_token, p.id, isActive);
        final i = procedures.indexWhere((x) => x.id == p.id);
        if (i != -1) procedures[i] = Procedure(id: p.id, name: p.name, isActive: isActive);
      });

  // ---------- Doctors ----------

  Future<String?> createDoctor(String name) => _run(() async {
        doctors.add(await _apiService.createDoctor(_token, name));
      });

  Future<String?> updateDoctor(int id, String name) => _run(() async {
        final updated = await _apiService.updateDoctor(_token, id, name);
        final i = doctors.indexWhere((d) => d.id == id);
        if (i != -1) doctors[i] = updated;
      });

  Future<String?> setDoctorStatus(Doctor d, bool isActive) => _run(() async {
        await _apiService.setDoctorStatus(_token, d.id, isActive);
        final i = doctors.indexWhere((x) => x.id == d.id);
        if (i != -1) doctors[i] = Doctor(id: d.id, name: d.name, isActive: isActive);
      });

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
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
