import 'package:flutter/material.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;

  const LoadingButton({
    super.key,
    this.color,
    required this.text,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppPallete.white,
        backgroundColor:
            isLoading
                ? color ?? AppPallete.dullprimary
                : color ?? AppPallete.primary,
        disabledBackgroundColor: color ?? AppPallete.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? const SizedBox(
                width: 19.2,
                height: 19.2,
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppPallete.white),
                  strokeWidth: 2,
                ),
              )
              : Text(text),
    );
  }
}
