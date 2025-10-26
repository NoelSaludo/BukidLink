import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class EmailAddressField extends StatelessWidget {
  final TextEditingController controller;
  const EmailAddressField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            "Email Address",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
        SizedBox(
          width: 312.0,
          height: 65.0,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
            child: TextFormField(
              decoration: InputDecoration(
                // labelText: 'Email Address',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14.0),
              controller: controller,
              validator: FormValidator().emailValidator,
            ),
          ),
        ),
      ],
    );
  }
}
