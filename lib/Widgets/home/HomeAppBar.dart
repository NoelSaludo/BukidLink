import 'package:bukidlink/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CartIconWithBadge.dart';
import 'package:bukidlink/Pages/AccountPage.dart';
import 'package:bukidlink/data/UserData.dart';

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountPage(
                            currentUser: UserService.currentUser,
                          ),
                        ),
                      );
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
