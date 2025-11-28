import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool useLoginGradient;

  const AuthButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.useLoginGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useLoginGradient) {
      // Match the Login button gradient and rounded styling
      return Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5C8D43),
              Color(0xFF9BCF6F),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.LOGIN_TEXT_FIELD_FILL,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
