import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bukidlink/Utils/PageNavigator.dart';
import 'package:bukidlink/Pages/HomePage.dart';
import 'package:bukidlink/Pages/farmer/FarmerStorePage.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

// TODO: @joelaguzar dito nagrouroute ang app pag naglaunch
class LoadingPage extends StatefulWidget {
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
      if (widget.userType == "Farmer") {
        PageNavigator().goTo(context, const FarmerStorePage());
      } else {
        PageNavigator().goTo(context, HomePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.LOGIN_BACKGROUND_START,
              AppColors.LOGIN_BACKGROUND_END,
            ],
          ),
        ),
        // Use a Stack so the circular logo sits exactly at the center of the screen
        // and the spinner/loading text can be positioned independently below it.
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered circular logo
            Center(
              child: Container(
                width: 350.0,
                height: 380.0,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.LOGIN_LOGO_BACKGROUND,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/bukidlink-main-logo.png',
                      width: 146.79,
                      height: 109.18,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BukidLink',
                      style: AppTextStyles.BUKIDLINK_LOGO,
                    ),
                  ],
                ),
              ),
            ),

            // Spinner and Loading text positioned below the centered circle
            // Use Align with a positive y value to place it below the center.
            Align(
              alignment: const Alignment(0, 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4.0,
                  ),
                  SizedBox(height: 16),
                  Text(
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
          ],
        ),
      ),
    );
  }
}
