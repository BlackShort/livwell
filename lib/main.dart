import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:livwell/config/routes/route_names.dart';
import 'package:livwell/config/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:livwell/config/routes/routes_page.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/firebase_options.dart' show DefaultFirebaseOptions;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter(); 
  await Hive.openBox('userBox');

  Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

  runApp(const LivWellApp());
}

class LivWellApp extends StatelessWidget {
  const LivWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      getPages: Routes.routes,
      initialRoute: AppRoute.wrapper,
    );
  }
}
