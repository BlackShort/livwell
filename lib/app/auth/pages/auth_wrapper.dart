import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/pages/login_page.dart';
import 'package:livwell/app/base/pages/base_page.dart';

class AuthWrapper extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.user.value == null) {
        return const LoginPage();
      } else {
        return const BasePage();
      }
    });
  }
}
