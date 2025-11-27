import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String mode;
  final String? forceErrorText;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  const EmailField({
    super.key,
    required this.controller,
    required this.mode,
    required this.forceErrorText,
    required this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == 'Login') {
      return SizedBox(
        width: 332.0,
        height: 90.0,
        child: TextFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.LOGIN_TEXT_FIELD_FILL,
            labelText: 'Email',
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
          ),
          style: const TextStyle(fontSize: 20.0),
          controller: controller,
          validator: FormValidator().loginEmailValildator,
          onChanged: onChanged,
        ),
      );
    } else if (mode == 'SignUp') {
      final validator = FormValidator();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "Username",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
          ),
          SizedBox(
            width: 312.0,
            height: 65.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0,
                  ),
                ),
                style: TextStyle(fontSize: 16.0),
                controller: controller,
                validator: validator.tempAddressValidator,
                onChanged: onChanged,
                // forceErrorText isn't a parameter of TextFormField; ignore here
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: 332.0,
        height: 90.0,
        child: TextFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Username',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
          ),
          style: TextStyle(fontSize: 20.0),
          obscureText: true,
          controller: controller,
          validator: FormValidator().signupUsernameValidator,
          onChanged: onChanged,
          // forceErrorText isn't a parameter of TextFormField; ignore here
        ),
      );
    }
  }
}
