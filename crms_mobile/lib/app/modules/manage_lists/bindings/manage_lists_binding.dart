import 'package:get/get.dart';

import '../controllers/manage_lists_controller.dart';

class ManageListsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ManageListsController());
  }
}
