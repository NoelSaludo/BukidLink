import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  //final VoidCallback onPressed;
 // final String mode;
  const FollowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 202, 232, 109),
          foregroundColor: Colors.black,
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Follow", style: TextStyle(fontSize: 20.0)),
      );
  }
}
