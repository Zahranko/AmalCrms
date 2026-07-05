import 'package:get/get.dart';

import '../controllers/system_params_controller.dart';

class SystemParamsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SystemParamsController>(() => SystemParamsController());
  }
}
