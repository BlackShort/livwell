import 'package:flutter/material.dart';
import 'package:livwell/app/activity/pages/activity_page.dart';
import 'package:livwell/app/base/models/bottom_bar_model.dart';
import 'package:livwell/app/base/widgets/custom_bottom_bar.dart';
import 'package:livwell/app/notification/notification_page.dart';
import 'package:livwell/app/profile/pages/profile_page.dart';
import 'package:livwell/app/registration/pages/registration_page.dart';
import 'package:livwell/app/home/pages/home_page.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomBar(
      items: [
        BottomBarModel(
          page: HomePage(),
          icon: 'assets/icons/home_out.svg',
          title: 'Home',
        ),
        BottomBarModel(
          page: const RegistrationPage(),
          icon: 'assets/icons/ticket_out.svg',
          title: 'Registration',
        ),
        BottomBarModel(
          page: const ActivityPage(),
          icon: 'assets/icons/activity_out.svg',
          title: 'Activity',
        ),
        BottomBarModel(
          page: const NotificationPage(),
          icon: 'assets/icons/bell_out.svg',
          title: 'Notification',
        ),
        BottomBarModel(
          page: ProfilePage(),
          icon: 'assets/icons/user_out.svg',
          title: 'Account',
        ),
      ],
    );
  }
}
