import 'package:flutter/material.dart';

class GoToSignUp extends StatelessWidget {
  final VoidCallback onPressed;
  const GoToSignUp({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Don't have an account yet?"),
        TextButton(onPressed: onPressed, child: Text('Sign Up')),
      ],
    );
  }
}
