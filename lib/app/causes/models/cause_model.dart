import 'package:flutter/material.dart';

class CauseModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color selectedColor;
  final bool isSelected;

  CauseModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.selectedColor,
    this.isSelected = false,
  });

  CauseModel copyWith({bool? isSelected}) {
    return CauseModel(
      id: id,
      name: name,
      icon: icon,
      color: color,
      selectedColor: selectedColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
