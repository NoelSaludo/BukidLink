import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.0,
      height: 380.0,
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME,
        shape: BoxShape.circle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Image.asset(
              'assets/icons/bukidlink_white_logo.png',
              width: 146.79,
              height: 109.18,
            ),
          ),
          Text('BukidLink', style: AppTextStyles.BUKIDLINK_LOGO),
        ],
      ),
    );
  }
}
