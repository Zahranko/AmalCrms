import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/website_setting.dart';
import '../../../data/services/api_service.dart';

/// Per-website "system parameters" (Admin only). Loads/saves the settings of the
/// active website — switching website re-scopes it via the X-Website-Id header.
class SystemParamsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final RxList<WebsiteSetting> settings = <WebsiteSetting>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxnString loadError = RxnString();
  final RxnString saveError = RxnString();
  final RxBool saved = false.obs;

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final result = await _apiService.getWebsiteSettings(_token);
      settings.assignAll(result);
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return;
      }
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Saves the given rows (blank keys dropped, keys must be unique). Returns true
  /// on success.
  Future<bool> save(List<WebsiteSetting> incoming) async {
    saveError.value = null;
    saved.value = false;

    final cleaned = incoming
        .where((s) => s.key.trim().isNotEmpty)
        .map((s) => WebsiteSetting(key: s.key.trim(), value: s.value))
        .toList();

    final keys = cleaned.map((s) => s.key.toLowerCase()).toList();
    if (keys.toSet().length != keys.length) {
      saveError.value = 'systemParams.duplicateKey'.tr;
      return false;
    }

    isSaving.value = true;
    try {
      await _apiService.saveWebsiteSettings(_token, cleaned);
      settings.assignAll(cleaned);
      saved.value = true;
      return true;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return false;
      }
      saveError.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
