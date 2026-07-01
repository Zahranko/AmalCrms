import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crms_mobile/app/controllers/auth_controller.dart';
import 'package:crms_mobile/app/data/services/language_service.dart';
import 'package:crms_mobile/app/data/services/storage_service.dart';
import 'package:crms_mobile/app/routes/app_routes.dart';
import 'package:crms_mobile/main.dart';

void main() {
  testWidgets('Login screen renders the sign-in form', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put(prefs);
    Get.put(LanguageService());
    Get.put(AuthController(StorageService(prefs)), permanent: true);

    await tester.pumpWidget(CrmsApp(
      initialRoute: Routes.login,
      initialLocale: const Locale('en', 'US'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
