import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/constants/AppColors.dart';
import 'package:bukidlink/Utils/constants/AppTextStyles.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // A circular branded header with logo, title and subtitle
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lift the logo slightly and make it stand out with a white border and shadow
        Transform.translate(
          offset: const Offset(0, -12),
          child: Container(
            width: 140.0,
            height: 140.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.LOGIN_LOGO_BACKGROUND,
              // white border so the logo pops against light rounded sheets
              border: Border.all(color: Colors.white, width: 8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/bukidlink-main-logo.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0), // reduce spacing because of the translate
        const Text('Create an Account', style: AppTextStyles.AUTH_TITLE),
        const SizedBox(height: 6.0),
        const Text("Let's get you started!", style: AppTextStyles.AUTH_SUBTITLE),
      ],
    );
  }
}
