import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  final VoidCallback onPressed;
  const ForgotPassword({super.key, required this.onPressed});
  
  @override
  Widget build(BuildContext context){
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Forgot Password?'
      ),
    );
  }
}