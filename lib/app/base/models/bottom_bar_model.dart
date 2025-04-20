import 'package:flutter/material.dart';

class BottomBarModel {
  final String title;
  final Widget page;
  final String? image;
  final IconData? icon;
  final Color? color;

  BottomBarModel({
    this.image,
    this.icon,
    this.color,
    required this.page,
    required this.title,
  });
}
