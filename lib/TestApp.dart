import 'package:flutter/material.dart';
import 'package:bukidlink/pages/HomePage.dart';

/// Test app to preview the HomePage
/// To use this, temporarily update main.dart to use this TestApp instead of App
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BukidLink HomePage Preview',
      theme: ThemeData(
        fontFamily: 'Outfit',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: const HomePage(),
    );
  }
}

