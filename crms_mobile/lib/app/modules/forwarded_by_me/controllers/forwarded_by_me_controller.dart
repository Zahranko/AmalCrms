import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/case_summary.dart';
import '../../../data/services/api_service.dart';

class ForwardedByMeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final RxList<CaseSummary> cases = <CaseSummary>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get _token => authController.session.value!.token;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      cases.assignAll(await _apiService.getForwardedByMe(_token));
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
