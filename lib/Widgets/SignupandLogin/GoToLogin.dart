import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class GoToLogin extends StatelessWidget {
  final VoidCallback onPressed;
  const GoToLogin({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Have an account?",
          style: AppTextStyles.BODY_MEDIUM,
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text('Log In', style: AppTextStyles.LINK_TEXT),
        ),
      ],
    );
  }
}
