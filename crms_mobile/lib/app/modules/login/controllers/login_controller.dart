import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';

/// Form-local state for the login screen. Session/login state itself lives
/// on the global AuthController so it survives navigation.
class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxnString fieldError = RxnString();

  String? get errorMessage => fieldError.value ?? authController.errorMessage.value;
  bool get isLoading => authController.isLoading.value;

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;

  Future<void> submit() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      fieldError.value = 'login.errorEmpty'.tr;
      return;
    }

    fieldError.value = null;
    await authController.login(username, password);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
