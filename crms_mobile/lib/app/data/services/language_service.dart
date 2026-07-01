import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxService {
  static const _key = 'lang';

  Future<LanguageService> init() async {
    return this;
  }

  Locale get currentLocale {
    final prefs = Get.find<SharedPreferences>();
    final lang = prefs.getString(_key) ?? 'en';
    return lang == 'ar' ? const Locale('ar', 'AR') : const Locale('en', 'US');
  }

  Future<void> toggleLanguage() async {
    final prefs = Get.find<SharedPreferences>();
    final current = prefs.getString(_key) ?? 'en';
    final next = current == 'ar' ? 'en' : 'ar';
    await prefs.setString(_key, next);
    Get.updateLocale(next == 'ar' ? const Locale('ar', 'AR') : const Locale('en', 'US'));
  }

  bool get isArabic {
    final prefs = Get.find<SharedPreferences>();
    return (prefs.getString(_key) ?? 'en') == 'ar';
  }
}
