import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

/// Reusable custom text field for farmer forms
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefix;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.enabled = true,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.FORM_LABEL.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.DARK_TEXT,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          enabled: enabled,
          style: AppTextStyles.BODY_MEDIUM.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: prefix,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: hint,
            hintStyle: AppTextStyles.TEXT_FIELD_HINT.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.HINT_TEXT_GREY.withOpacity(0.7),
            ),
            filled: true,
            fillColor: enabled ? AppColors.BACKGROUND_WHITE : AppColors.INACTIVE_GREY.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.BORDER_GREY.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.BORDER_GREY.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.ERROR_RED,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.ERROR_RED,
                width: 2.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines != null && maxLines! > 1 ? 16 : 14,
            ),
            counterText: '',
            errorStyle: TextStyle(
              fontFamily: AppTextStyles.FONT_FAMILY,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.ERROR_RED,
            ),
          ),
        ),
      ],
    );
  }
}
