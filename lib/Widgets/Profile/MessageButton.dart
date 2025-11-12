import 'package:flutter/material.dart';

class MessageButton extends StatelessWidget {
  final VoidCallback onPressed;
  const MessageButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 202, 232, 109),
          foregroundColor: Colors.black,
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text("Message", style: TextStyle(fontSize: 20.0)),
      );
  }
}
