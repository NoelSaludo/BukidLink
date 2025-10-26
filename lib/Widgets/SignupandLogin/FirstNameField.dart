import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class FirstNameField extends StatelessWidget {
  final TextEditingController controller;
  const FirstNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text("First Name", style: AppTextStyles.FORM_LABEL),
        ),
        SizedBox(
          width: 155.0,
          height: 65.0,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 4.0),
            child: TextFormField(
              decoration: InputDecoration(
                // labelText: 'FirstName',
                filled: true,
                fillColor: AppColors.INACTIVE_GREY,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors.BORDER_GREY,
                    width: 2.0,
                  ),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
              ),
              style: AppTextStyles.BODY_MEDIUM,
              controller: controller,
              validator: FormValidator().nameValidator,
            ),
          ),
        ),
      ],
    );
  }
}
