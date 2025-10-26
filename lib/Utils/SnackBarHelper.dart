import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class SnackBarHelper {
  SnackBarHelper._();

  // custom snackbar with icon and message
  static void showSnackBar(
    BuildContext context, {
    required IconData icon,
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // success snackbar
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      icon: Icons.check_circle,
      message: message,
      backgroundColor: AppColors.primaryGreen,
    );
  }

  // error snackbar
  static void showError(BuildContext context, String message) {
    showSnackBar(
      context,
      icon: Icons.error,
      message: message,
      backgroundColor: AppColors.ERROR_RED,
    );
  }

  // show info snackbar
  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context,
      icon: Icons.info,
      message: message,
      backgroundColor: AppColors.HEADER_GRADIENT_START,
    );
  }

  // show warning snackbar
  static void showWarning(BuildContext context, String message) {
    showSnackBar(
      context,
      icon: Icons.warning,
      message: message,
      backgroundColor: AppColors.WARNING_ORANGE,
    );
  }
}
