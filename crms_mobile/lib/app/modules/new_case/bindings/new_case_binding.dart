import 'package:get/get.dart';

import '../controllers/new_case_controller.dart';

class NewCaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewCaseController>(() => NewCaseController());
  }
}
