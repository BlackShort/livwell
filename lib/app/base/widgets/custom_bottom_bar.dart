import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/app/activity/pages/activity_page.dart';
import 'package:livwell/app/base/controllers/base_controller.dart';
import 'package:livwell/app/base/models/bottom_bar_model.dart';
import 'package:livwell/app/home/pages/home_page.dart';
import 'package:livwell/app/notification/notification_page.dart';
import 'package:livwell/app/profile/pages/profile_page.dart';
import 'package:livwell/app/registration/pages/registration_page.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class CustomBottomBar extends StatelessWidget {
  final bool appear;
  final List<BottomBarModel>? items;

  static final List<BottomBarModel> defaultItems = [
    BottomBarModel(
      page: HomePage(),
      icon: Icons.home_rounded,
      title: 'Home',
    ),
    BottomBarModel(
      page: const RegistrationPage(),
      icon: Icons.confirmation_number,
      title: 'Registration',
    ),
    BottomBarModel(
      page: const ActivityPage(),
      icon: Icons.assessment,
      title: 'Activity',
    ),
    BottomBarModel(
      page: const NotificationPage(),
      icon: Icons.notifications,
      title: 'Notification',
    ),
    BottomBarModel(
      page: const ProfilePage(),
      icon: Icons.person,
      title: 'Account',
    ),
  ];

  const CustomBottomBar({super.key, this.appear = true, this.items});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BaseController());

    if (appear) {
      controller.showBottomBar();
    } else {
      controller.hideBottomBar();
    }

    final navItems = items ?? defaultItems;

    return Obx(() {
      if (!controller.isBottomBarVisible.value) {
        return const SizedBox.shrink(); 
      }

      return BottomNavigationBar(
        currentIndex: controller.selectedTab.value,
        elevation: 2,
        selectedItemColor: const Color(0xCE1E1E1E),
        unselectedItemColor: const Color(0xFF9E9E9E),
        backgroundColor: const Color(0xFFF5F5F5),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          controller.selectedTab.value = index;
        },
        items: navItems.map((item) => _buildNavigationBarItem(item)).toList(),
      );
    });
  }

  // Helper method to build navigation bar items
  BottomNavigationBarItem _buildNavigationBarItem(BottomBarModel item) {
    return BottomNavigationBarItem(
      icon: _buildIcon(item, false),
      activeIcon: _buildIcon(item, true),
      label: item.title,
    );
  }

  // Helper method to build icon or image
  Widget _buildIcon(BottomBarModel item, bool isActive) {
    final color =
        isActive ? item.color ?? AppPallete.primary : const Color(0xFF9E9E9E);

    // Check if we should use icon or image
    if (item.icon != null) {
      return Icon(item.icon, color: color);
    } else if (item.image != null) {
      return SvgPicture.asset(
        item.image!,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    // Fallback to a default icon
    return Icon(Icons.circle, color: color);
  }
}
