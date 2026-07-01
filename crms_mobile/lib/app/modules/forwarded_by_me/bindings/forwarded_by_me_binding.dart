import 'package:get/get.dart';

import '../controllers/forwarded_by_me_controller.dart';

class ForwardedByMeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForwardedByMeController>(() => ForwardedByMeController());
  }
}
