import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/app_user.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_routes.dart';

class UsersController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final RxList<AppUser> users = <AppUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  String get _token => authController.session.value!.token;
  String get currentUsername => authController.session.value?.username ?? '';

  @override
  void onInit() {
    super.onInit();
    if (authController.session.value?.role != 'Admin') {
      Future.microtask(() => Get.offNamed(Routes.dashboard));
      return;
    }
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _apiService.getUsers(_token);
      users.assignAll(result);
    } catch (e) {
      await _reportError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createUser({required String username, required String password, required String role}) =>
      _run(() async {
        final created = await _apiService.createUser(_token, username: username, password: password, role: role);
        users.add(created);
      });

  Future<String?> updateUser(int id, {required String username, required String role, required bool notifyOnNewCase}) => _run(() async {
        final updated = await _apiService.updateUser(_token, id, username: username, role: role, notifyOnNewCase: notifyOnNewCase);
        final index = users.indexWhere((u) => u.id == id);
        if (index != -1) users[index] = updated;
      });

  Future<String?> resetPassword(int id, String newPassword) =>
      _run(() => _apiService.resetUserPassword(_token, id, newPassword));

  Future<String?> setStatus(AppUser user, bool isActive) => _run(() async {
        await _apiService.setUserStatus(_token, user.id, isActive);
        final index = users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          users[index] = AppUser(
            id: user.id,
            username: user.username,
            role: user.role,
            isActive: isActive,
            notifyOnNewCase: user.notifyOnNewCase,
            createdAt: user.createdAt,
          );
        }
      });

  /// Runs an action and returns an error message on failure, or null on success.
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

  Future<void> _reportError(Object e) async {
    if (e is UnauthorizedException) {
      await authController.logout();
      return;
    }
    errorMessage.value = e.toString();
  }
}
