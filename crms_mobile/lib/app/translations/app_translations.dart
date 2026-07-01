import 'package:get/get.dart';
import 'en_us.dart';
import 'ar_ar.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'ar_AR': arAr,
      };
}
