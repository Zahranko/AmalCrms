import 'package:get/get.dart';

import '../controllers/case_detail_controller.dart';

class CaseDetailBinding extends Bindings {
  @override
  void dependencies() {
    final caseId = Get.arguments as int;
    Get.lazyPut<CaseDetailController>(() => CaseDetailController(caseId));
  }
}
