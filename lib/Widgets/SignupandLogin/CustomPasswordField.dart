import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleObscureText;
  final ValueChanged<String> onChanged;
  final String label;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.toggleObscureText,
    required this.onChanged,
    this.label = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    final validator = FormValidator();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
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
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: toggleObscureText,
                ),
              ),
              style: const TextStyle(fontSize: 16.0),
              controller: controller,
              obscureText: obscureText,
              validator: validator.tempAddressValidator,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

