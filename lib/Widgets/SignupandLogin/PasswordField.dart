import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String mode;
  const PasswordField({
    super.key,
    required this.controller,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == 'Login') {
      return SizedBox(
        width: 332.0,
        height: 90.0,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Password',
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
          validator: FormValidator().loginPasswordValidator,
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
              "Password",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          SizedBox(
            width: 312.0,
            height: 65.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
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
                style: TextStyle(fontSize: 14.0),
                controller: controller,
                validator: validator.tempAddressValidator,
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
          decoration: InputDecoration(
            labelText: 'Password',
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
          validator: FormValidator().signupPasswordValidator,
        ),
      );
    }
  }
}
