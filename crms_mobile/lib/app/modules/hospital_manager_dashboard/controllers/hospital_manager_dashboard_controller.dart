import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/hospital_manager_stats.dart';
import '../../../data/services/api_service.dart';

enum HmQuickFilter { thisMonth, lastMonth, allTime, custom }

class HospitalManagerDashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final Rxn<HospitalManagerStats> stats = Rxn<HospitalManagerStats>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final Rx<HmQuickFilter> quickFilter = HmQuickFilter.thisMonth.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    applyQuickFilter(HmQuickFilter.thisMonth);
  }

  void applyQuickFilter(HmQuickFilter filter) {
    quickFilter.value = filter;
    final now = DateTime.now();
    switch (filter) {
      case HmQuickFilter.thisMonth:
        fromDate.value = DateTime(now.year, now.month, 1);
        toDate.value = now;
        break;
      case HmQuickFilter.lastMonth:
        fromDate.value = DateTime(now.year, now.month - 1, 1);
        toDate.value = DateTime(now.year, now.month, 0);
        break;
      case HmQuickFilter.allTime:
        fromDate.value = null;
        toDate.value = null;
        break;
      case HmQuickFilter.custom:
        // Caller sets fromDate/toDate directly (via a date-range picker) then calls loadStats().
        return;
    }
    loadStats();
  }

  void setCustomRange(DateTime from, DateTime to) {
    quickFilter.value = HmQuickFilter.custom;
    fromDate.value = from;
    toDate.value = to;
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      stats.value = await _apiService.getHospitalManagerStats(_token, from: fromDate.value, to: toDate.value);
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
}
