import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class GoToSignUp extends StatelessWidget {
  final VoidCallback onPressed;
  const GoToSignUp({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account yet?",
          style: AppTextStyles.BODY_MEDIUM,
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text('Sign Up', style: AppTextStyles.LINK_TEXT),
        ),
      ],
    );
  }
}
