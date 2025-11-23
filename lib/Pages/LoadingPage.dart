import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bukidlink/Utils/PageNavigator.dart';
import 'package:bukidlink/Pages/HomePage.dart';

// TODO: @joelaguzar dito nagrouroute ang app pag naglaunch
class LoadingPage extends StatefulWidget {
  // pede mo to gamitin to distinguish user types
  // at to route accordingly sa HomePage
  final String userType;
  const LoadingPage({super.key, required this.userType});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    // Simulate loading or initialization delay
    Future.delayed(const Duration(seconds: 3), () {
      PageNavigator().goTo(context, HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 98, 41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                    padding: EdgeInsets.only(top: 100),
                    child: Image.asset(
                      'assets/icons/bukidlink_white_logo.png',
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
            ),

            const SizedBox(height: 50),

            // Loading spinner
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4.0,
            ),

            const SizedBox(height: 20),

            const Text(
              "Loading...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
