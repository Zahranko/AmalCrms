import 'package:get/get.dart';

import '../data/models/user_session.dart';
import '../data/models/website.dart';
import '../data/services/active_website.dart';
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
  final Rxn<Website> activeWebsite = Rxn<Website>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isLoggedIn => session.value != null;

  @override
  void onInit() {
    super.onInit();
    session.value = _storageService.readSession();
    final active = _storageService.readActiveWebsite();
    if (active != null) {
      activeWebsite.value = active;
      ActiveWebsite.id = active.id;
    }
  }

  Future<void> login(String username, String password) async {
    errorMessage.value = null;
    isLoading.value = true;
    try {
      final result = await _apiService.login(username, password);

      if (result.websites.isEmpty) {
        errorMessage.value = 'login.noWebsiteAccess'.tr;
        return;
      }

      session.value = result;
      await _storageService.saveSession(result);
      if (Get.isRegistered<NotificationCenterController>()) {
        Get.find<NotificationCenterController>().start();
      }

      if (result.websites.length == 1) {
        _applyActiveWebsite(result.websites.first);
        Get.offAllNamed(homeRouteFor(result.role, result.websites.first.key));
      } else {
        Get.offAllNamed(Routes.websitePicker);
      }
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
    activeWebsite.value = null;
    ActiveWebsite.id = null;
    await _storageService.clearSession();
    Get.offAllNamed(Routes.login);
  }

  /// Picks a website (from the picker or the drawer switcher) and enters it.
  void setActiveWebsite(Website website) {
    _applyActiveWebsite(website);
    Get.offAllNamed(homeRouteFor(session.value!.role, website.key));
  }

  void _applyActiveWebsite(Website website) {
    activeWebsite.value = website;
    ActiveWebsite.id = website.id;
    _storageService.saveActiveWebsite(website);
  }

  /// Cold-start routing (used by main.dart). Assumes the user is logged in.
  String resolveInitialRoute() {
    final s = session.value!;

    if (s.websites.isEmpty) {
      // Legacy session saved before multi-website — force a fresh login.
      session.value = null;
      ActiveWebsite.id = null;
      _storageService.clearSession();
      return Routes.login;
    }

    final active = activeWebsite.value;
    if (active != null && s.websites.any((w) => w.id == active.id)) {
      return homeRouteFor(s.role, active.key);
    }
    if (s.websites.length == 1) {
      _applyActiveWebsite(s.websites.first);
      return homeRouteFor(s.role, s.websites.first.key);
    }
    return Routes.websitePicker;
  }

  static String homeRouteFor(String role, String websiteKey) {
    if (websiteKey == 'contact') return Routes.contact;
    return dashboardRouteForRole(role);
  }

  static String dashboardRouteForRole(String role) {
    if (role == 'Admin') return Routes.adminDashboard;
    if (role == 'HospitalManager') return Routes.hospitalManagerDashboard;
    return Routes.dashboard;
  }
}
