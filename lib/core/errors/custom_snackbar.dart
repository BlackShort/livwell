import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  // Show success snackbar
  static void showSuccess({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.success,
    );
  }

  // Show failure snackbar
  static void showError({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.failure,
    );
  }

  // Show warning snackbar
  static void showWarning({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.warning,
    );
  }

  // Show info snackbar
  static void showInfo({
    required String title,
    required String message,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.info,
    );
  }

  // Private method to show GetX Snackbar
  static void _showSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
  }) {
    // Define icon and color based on type
    IconData icon;
    Color bgColor;
    Color borderColor;

    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle;
        bgColor = Colors.green;
        borderColor = Colors.greenAccent;
        break;
      case SnackbarType.failure:
        icon = Icons.error;
        bgColor = Colors.red;
        borderColor = Colors.redAccent;
        break;
      case SnackbarType.warning:
        icon = Icons.warning;
        bgColor = Colors.orange;
        borderColor = Colors.orangeAccent;
        break;
      case SnackbarType.info:
        icon = Icons.info;
        bgColor = Colors.blue;
        borderColor = Colors.blueAccent;
        break;
    }

    // Show GetX Snackbar
    Get.snackbar(
      title, // Snackbar title
      message, // Snackbar message
      snackPosition: SnackPosition.BOTTOM, // Snackbar position
      backgroundColor: bgColor, // Background color
      colorText: Colors.white, // Text color
      icon: Icon(icon, color: Colors.white), // Icon
      margin: const EdgeInsets.all(16), // Padding around snackbar
      borderRadius: 8, // Rounded corners
      borderColor: borderColor, // Border color
      borderWidth: 2, // Border thickness
      isDismissible: true, // Allow user to dismiss it
      duration: const Duration(seconds: 6), // Auto-close time
      forwardAnimationCurve: Curves.easeIn, // Animation
      reverseAnimationCurve: Curves.easeOut, // Animation
      animationDuration: const Duration(milliseconds: 400), // Animation speed
    );
  }
}

// Enum to define snackbar types
enum SnackbarType { success, failure, warning, info }