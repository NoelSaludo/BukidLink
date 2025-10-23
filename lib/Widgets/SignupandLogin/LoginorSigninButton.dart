import 'package:flutter/material.dart';

class LoginorSigninButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String mode;
  LoginorSigninButton({super.key, required this.onPressed, required this.mode});

  @override
  Widget build(BuildContext context) {
    if(mode == 'Login'){
      return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 202, 232, 109),
        foregroundColor: Colors.black,
        minimumSize: const Size(150, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: 
      const Text(
        "Log In",
        style: TextStyle(
          fontSize: 24.0,
        )
        ),
    );
    }
    else if(mode == 'SignUp'){
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
      child: 
      const Text(
        "Continue",
        style: TextStyle(
          fontSize: 24.0,
        )
        ),
        
    );
    }
    else{
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
      child: 
      const Text(
        "Create Account",
        style: TextStyle(
          fontSize: 24.0,
        )
        ),
    );
    }
  }
}

