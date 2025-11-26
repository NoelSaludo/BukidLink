import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final IconData? icon;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: hintText,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.DARK_GREEN) : null,
          filled: true,
          fillColor: AppColors.LOGIN_TEXT_FIELD_FILL,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
              color: AppColors.LOGIN_TEXT_FIELD_BORDER,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
              color: AppColors.LOGIN_TEXT_FIELD_BORDER,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
              color: AppColors.HEADER_GRADIENT_START,
              width: 2.0,
            ),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
        style: const TextStyle(fontSize: 20.0),
      ),
    );
  }
}
