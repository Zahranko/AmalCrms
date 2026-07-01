import 'package:get/get.dart';

import '../controllers/forwarded_cases_controller.dart';

class ForwardedCasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForwardedCasesController>(() => ForwardedCasesController());
  }
}
