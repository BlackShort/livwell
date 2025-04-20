import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/base/controllers/base_controller.dart';
import 'package:livwell/app/base/widgets/custom_bottom_bar.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseController = Get.put(BaseController());
    final navItems = CustomBottomBar.defaultItems;
    
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: baseController.selectedTab.value,
          children: navItems
            .asMap()
            .map(
              (index, item) => MapEntry(
                index,
                Navigator(
                  key: baseController.navigatorKeys[index],
                  onGenerateInitialRoutes: (navigator, initialRoute) {
                    return [GetPageRoute(page: () => item.page)];
                  },
                ),
              ),
            )
            .values
            .toList(),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(appear: true),
    );
  }
}