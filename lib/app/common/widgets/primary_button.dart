import 'package:flutter/material.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Widget? startIcon;
  final Widget? endIcon;

  const PrimaryButton({
    super.key,
    this.color,
    required this.text,
    required this.onPressed,
    this.startIcon,
    this.endIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppPallete.white,
        backgroundColor: color ?? AppPallete.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (startIcon != null) ...[
            startIcon!,
            const SizedBox(width: 8),
          ],
          Text(text),
          if (endIcon != null) ...[
            const SizedBox(width: 8),
            endIcon!,
          ],
        ],
      ),
    );
  }
}