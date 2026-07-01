import 'package:get/get.dart';

import '../modules/admin_dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin_dashboard/views/admin_dashboard_view.dart';
import '../modules/case_detail/bindings/case_detail_binding.dart';
import '../modules/case_detail/views/case_detail_view.dart';
import '../modules/cases/bindings/cases_binding.dart';
import '../modules/cases/views/cases_view.dart';
import '../modules/forwarded_by_me/bindings/forwarded_by_me_binding.dart';
import '../modules/forwarded_by_me/views/forwarded_by_me_view.dart';
import '../modules/forwarded_cases/bindings/forwarded_cases_binding.dart';
import '../modules/forwarded_cases/views/forwarded_cases_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/manage_lists/bindings/manage_lists_binding.dart';
import '../modules/manage_lists/views/manage_lists_view.dart';
import '../modules/new_case/bindings/new_case_binding.dart';
import '../modules/new_case/views/new_case_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/users_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const CasesView(),
      binding: CasesBinding(),
    ),
    GetPage(
      name: Routes.newCase,
      page: () => const NewCaseView(),
      binding: NewCaseBinding(),
    ),
    GetPage(
      name: Routes.caseDetail,
      page: () => const CaseDetailView(),
      binding: CaseDetailBinding(),
    ),
    GetPage(
      name: Routes.forwardedCases,
      page: () => const ForwardedCasesView(),
      binding: ForwardedCasesBinding(),
    ),
    GetPage(
      name: Routes.forwardedByMe,
      page: () => const ForwardedByMeView(),
      binding: ForwardedByMeBinding(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.manageLists,
      page: () => const ManageListsView(),
      binding: ManageListsBinding(),
    ),
    GetPage(
      name: Routes.userManage,
      page: () => const UsersView(),
      binding: UsersBinding(),
    ),
  ];
}
