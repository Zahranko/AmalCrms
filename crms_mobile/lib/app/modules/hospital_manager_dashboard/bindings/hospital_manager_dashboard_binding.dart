import 'package:get/get.dart';

import '../controllers/hospital_manager_dashboard_controller.dart';

class HospitalManagerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalManagerDashboardController>(() => HospitalManagerDashboardController());
  }
}
