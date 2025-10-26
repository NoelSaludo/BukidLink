import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class ForgotPassword extends StatelessWidget {
  final VoidCallback onPressed;
  const ForgotPassword({super.key, required this.onPressed});
  
  @override
  Widget build(BuildContext context){
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Forgot Password?',
        style: AppTextStyles.FORGOT_PASSWORD,
      ),
    );
  }
}