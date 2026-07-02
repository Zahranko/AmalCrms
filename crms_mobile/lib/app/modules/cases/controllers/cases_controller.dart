import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../data/models/case_summary.dart';
import '../../../data/services/api_service.dart';

/// The cases hub (dashboard). Mirrors employeeDashboard.js: loads every case
/// once and filters client-side by All / Today / Assigned to me / Unassigned,
/// plus a name/phone search. Anyone can claim an unassigned case.
enum CaseFilter { all, today, mine, unassigned }

class CasesController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _apiService = ApiService();

  final RxList<CaseSummary> allCases = <CaseSummary>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  final Rx<CaseFilter> filter = CaseFilter.all.obs;
  final RxString search = ''.obs;
  // Debounced copy of `search` that the list actually filters on, so the whole
  // list isn't re-filtered and re-rendered on every keystroke.
  final RxString _debouncedSearch = ''.obs;
  final RxnInt claimingId = RxnInt();

  String get _token => authController.session.value!.token;
  String get _username => authController.session.value!.username;

  @override
  void onInit() {
    super.onInit();
    debounce(search, (String v) => _debouncedSearch.value = v, time: const Duration(milliseconds: 250));
    loadCases();
  }

  Future<void> loadCases() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      allCases.assignAll(await _apiService.getAllCases(_token));
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

  List<CaseSummary> get visibleCases {
    final now = DateTime.now();
    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    var result = allCases.where((c) {
      switch (filter.value) {
        case CaseFilter.today:
          return isToday(c.createdAt.toLocal());
        case CaseFilter.mine:
          return c.assignedToUsername == _username;
        case CaseFilter.unassigned:
          return c.assignedToUsername == null || c.assignedToUsername!.isEmpty;
        case CaseFilter.all:
          return true;
      }
    });

    final term = _debouncedSearch.value.trim().toLowerCase();
    if (term.isNotEmpty) {
      result = result.where((c) {
        final phone = '${c.phoneCountryCode}${c.phoneNumber}'.toLowerCase();
        return c.name.toLowerCase().contains(term) || phone.contains(term);
      });
    }

    return result.toList();
  }

  bool isMine(CaseSummary c) => c.assignedToUsername == _username;

  Future<String?> claim(CaseSummary c) async {
    claimingId.value = c.id;
    try {
      await _apiService.claimCase(_token, c.id);
      await loadCases();
      return null;
    } catch (e) {
      if (e is UnauthorizedException) {
        await authController.logout();
        return null;
      }
      return e.toString();
    } finally {
      claimingId.value = null;
    }
  }
}
