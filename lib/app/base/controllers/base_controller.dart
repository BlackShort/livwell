// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class BaseController extends GetxController {
//   final selectedTab = 0.obs;
//   final navigatorKeys = List<GlobalKey<NavigatorState>>.generate(
//     5, // Adjust the number to match your tabs
//     (index) => GlobalKey<NavigatorState>(),
//   );
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseController extends GetxController {
  static BaseController get to => Get.find();
  
  // For bottom navigation bar
  final selectedTab = 0.obs;
  final navigatorKeys = List.generate(5, (index) => GlobalKey<NavigatorState>());
  
  // To control visibility
  final isBottomBarVisible = true.obs;
  
  // Methods to show/hide bottom bar
  void showBottomBar() => isBottomBarVisible.value = true;
  void hideBottomBar() => isBottomBarVisible.value = false;
  
  // Change tab method
  void changeTab(int index) {
    selectedTab.value = index;
  }
}