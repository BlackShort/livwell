import 'package:flutter/material.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset(icon, height: 24),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppPallete.grey,
          side: const BorderSide(color: AppPallete.grey, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppPallete.primary,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
