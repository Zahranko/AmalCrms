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
  Get.put(NotificationCenterController(), permanent: true);

  final initialRoute = authController.isLoggedIn ? authController.resolveInitialRoute() : Routes.login;

  runApp(CrmsApp(initialRoute: initialRoute, initialLocale: langService.currentLocale));

  // Request permission AFTER runApp so the Android Activity is live.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    LocalNotificationsService.instance.requestPermissions();
  });
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
      // Fade instead of the default abrupt cut; direction-neutral so it reads
      // the same in RTL (Arabic) as in LTR.
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 220),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
