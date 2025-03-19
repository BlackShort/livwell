import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/app/base/controllers/base_controller.dart';
import 'package:livwell/app/base/models/bottom_bar_model.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class CustomBottomBar extends StatefulWidget {
  final List<BottomBarModel> items;

  const CustomBottomBar({super.key, required this.items});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  final _baseController = Get.put(BaseController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: _baseController.selectedTab.value,
          children: widget.items
              .asMap()
              .map((index, item) => MapEntry(
                    index,
                    Navigator(
                      key: _baseController.navigatorKeys[index],
                      onGenerateInitialRoutes: (navigator, initialRoute) {
                        return [
                          GetPageRoute(page: () => item.page),
                        ];
                      },
                    ),
                  ))
              .values
              .toList(),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: _baseController.selectedTab.value,
          elevation: 2,
          selectedItemColor: const Color(0xCE1E1E1E),
          unselectedItemColor: const Color(0xFF9E9E9E),
          backgroundColor: const Color(0xFFF5F5F5),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            _baseController.selectedTab.value = index;
          },
          items: widget.items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    item.icon,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF9E9E9E),
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    item.icon,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      item.color ?? AppPallete.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: item.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}