import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      width: 350.0,
      height: 380.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 202, 232, 109),
        shape: BoxShape.circle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: Image.asset(
          'assets/Logo.png',
          width: 146.79,
          height: 109.18,
        ),
        ),
        Text(
          'BukidLink',
          style: TextStyle(
            height: 0.8,
            fontSize: 50.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
        ),
      ],
      ),
      );
  }
}