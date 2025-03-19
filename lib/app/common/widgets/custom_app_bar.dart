import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/config/routes/route_names.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class SimpleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? leading;
  final String? actions;
  final bool centerTitle;
  final String? routeName;
  final double? titleSpacing;
  final Color backgroundColor;
  final VoidCallback? callback;
  final VoidCallback? frontCallback;

  const SimpleAppbar({
    super.key,
    this.title,
    this.leading = 'assets/icons/menu_fill.svg',
    this.actions,
    this.centerTitle = false,
    this.routeName,
    this.titleSpacing = 0,
    this.backgroundColor = Colors.white,
    this.callback,
    this.frontCallback,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: SvgPicture.asset(
            leading ?? 'assets/icons/menu_fill.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppPallete.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: frontCallback ??
              () {
                if (routeName == null || routeName == 'default') {
                  Scaffold.of(context).openDrawer();
                } else {
                  Get.back();
                }
              },
        ),
      ),
      titleSpacing: titleSpacing,
      title: Text(
        title ?? AppConstants.appName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppPallete.secondary,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            actions ?? 'assets/icons/bell_out.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppPallete.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: callback ??
              () {
                if (routeName != null) {
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