import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class AddressField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  const AddressField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validator = FormValidator();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: AppTextStyles.FORM_LABEL,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                filled: true,
                fillColor: AppColors.LOGIN_TEXT_FIELD_FILL,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
              style: const TextStyle(fontSize: 14.0),
              controller: controller,
              validator: validator.tempAddressValidator,
              onChanged: onChanged,
              maxLines: 3,
            ),
          ),
        ),
      ],
    );
  }
}
