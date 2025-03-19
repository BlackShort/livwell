import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/config/routes/route_names.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? leading;
  final String? actions;
  final String? routeName;
  final VoidCallback? callback;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.routeName,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          fontFamily: 'Poippins',
          fontWeight: FontWeight.w600,
          color: title != null ? AppPallete.secondary : AppPallete.primary,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/slider_out.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppPallete.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            if (callback != null) {
              callback!();
            } else if (routeName != null) {
              Get.toNamed(routeName!);
            } else {
              Get.toNamed(AppRoute.notification);
            }
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/slider_out.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppPallete.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            if (callback != null) {
              callback!();
            } else if (routeName != null) {
              Get.toNamed(routeName!);
            } else {
              Get.toNamed(AppRoute.notification);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
