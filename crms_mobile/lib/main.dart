import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/notification_center_controller.dart';
import 'app/data/services/language_service.dart';
import 'app/data/services/local_notifications_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationsService.instance.init();

  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  final langService = LanguageService();
  await langService.init();
  Get.put(langService);

  final authController = Get.put(AuthController(StorageService(prefs)), permanent: true);
  // Registered after auth so it can read the session; polls only while logged in.
  Get.put(NotificationCenterController(), permanent: true);

  // Ask for notification permission up front (no-op on platforms that don't need it).
  await LocalNotificationsService.instance.requestPermissions();

  runApp(CrmsApp(
    initialRoute: authController.isLoggedIn ? Routes.dashboard : Routes.login,
    initialLocale: langService.currentLocale,
  ));
}

class CrmsApp extends StatelessWidget {
  final String initialRoute;
  final Locale initialLocale;

  const CrmsApp({super.key, required this.initialRoute, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CRMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
