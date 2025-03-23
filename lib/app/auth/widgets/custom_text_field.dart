import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly; 
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
