import 'package:get/get.dart';

import '../data/models/user_session.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';
import '../routes/app_routes.dart';
import 'notification_center_controller.dart';

/// Global session controller, registered once for the app's lifetime
/// (see main.dart). Equivalent to the session helpers in api.js plus the
/// AuthService on the backend.
class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService;

  AuthController(this._storageService);

  final Rxn<UserSession> session = Rxn<UserSession>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isLoggedIn => session.value != null;

  @override
  void onInit() {
    super.onInit();
    session.value = _storageService.readSession();
  }

  Future<void> login(String username, String password) async {
    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _apiService.login(username, password);
      session.value = result;
      await _storageService.saveSession(result);
      if (Get.isRegistered<NotificationCenterController>()) {
        Get.find<NotificationCenterController>().start();
      }
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    if (Get.isRegistered<NotificationCenterController>()) {
      Get.find<NotificationCenterController>().stop();
    }
    session.value = null;
    await _storageService.clearSession();
    Get.offAllNamed(Routes.login);
  }
}
