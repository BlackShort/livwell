import 'package:flutter/material.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = AppPallete.secondary]) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  static final ThemeData theme = ThemeData(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: AppPallete.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.white,
      iconTheme: IconThemeData(color: AppPallete.black),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPallete.white,
      selectedItemColor: AppPallete.primary,
      unselectedItemColor: AppPallete.secondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primary,
        foregroundColor: AppPallete.white,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 4,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPallete.primary,
        side: const BorderSide(color: AppPallete.primary, width: 2),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppPallete.black,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppPallete.black,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        color: AppPallete.secondary,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: _border(),
      focusedBorder: _border(AppPallete.primary),
      errorBorder: _border(AppPallete.errorColor),
      focusedErrorBorder: _border(AppPallete.errorColor),
      labelStyle: const TextStyle(
        color: AppPallete.secondary,
        fontFamily: 'Poppins',
      ),
      errorStyle: const TextStyle(
        color: AppPallete.errorColor,
        fontFamily: 'Poppins',
      ),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: AppPallete.errorColor);
          }
          return const TextStyle(color: AppPallete.secondary);
        },
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppPallete.backgroundColor,
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
