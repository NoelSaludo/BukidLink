import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.HEADER_GRADIENT_START,
            AppColors.HEADER_GRADIENT_END,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      print("Chat tapped");
                    },
                  ),
                  const Text(
                    'BukidLink',
                    style: AppTextStyles.BUKIDLINK_LOGO,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      print("Cart tapped");
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      print("Profile tapped");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

