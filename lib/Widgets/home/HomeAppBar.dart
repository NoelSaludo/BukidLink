import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CartIconWithBadge.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback? onCartPressed;

  const HomeAppBar({
    super.key,
    this.onCartPressed,
  });

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
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      print("Chat tapped");
                    },
                  ),
                  const Text('BukidLink', style: AppTextStyles.BUKIDLINK_LOGO),
                ],
              ),
              Row(
                children: [
                  CartIconWithBadge(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (onCartPressed != null) {
                        onCartPressed!();
                      } else {
                        print("Cart tapped");
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
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
