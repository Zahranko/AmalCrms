import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/admin_stats.dart';
import '../../../data/services/api_service.dart';

class AdminDashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final Rxn<AdminStats> stats = Rxn<AdminStats>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      stats.value = await _apiService.getAdminStats(_token);
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
