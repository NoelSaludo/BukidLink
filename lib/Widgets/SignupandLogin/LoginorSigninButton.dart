import 'package:flutter/material.dart';

class LoginorSigninButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String mode;
  LoginorSigninButton({super.key, required this.onPressed, required this.mode});

  @override
  Widget build(BuildContext context) {
    if (mode == 'Login') {
      return Container(
        width: 260,
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
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            minimumSize: const Size(260, 55), // enforce same minimum size
          ),
          child: const Text(
            "Log In",
            style: TextStyle(
              fontSize: 20.0, // slightly smaller for better balance
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (mode == 'SignUp') {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 250, 228, 185),
          foregroundColor: Colors.black,
          minimumSize: const Size(310, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text("Continue", style: TextStyle(fontSize: 24.0)),
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 250, 228, 185),
          foregroundColor: Colors.black,
          minimumSize: const Size(310, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Create Account", style: TextStyle(fontSize: 24.0)),
      );
    }
  }
}
