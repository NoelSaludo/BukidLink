import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/widgets/common/CartIconWithBadge.dart';
import 'package:bukidlink/pages/CartPage.dart';

class CategoryAppBar extends StatelessWidget {
  final String categoryName;
  final String categoryIcon;

  const CategoryAppBar({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  void _handleCartPressed(BuildContext context) {
    HapticFeedback.lightImpact();
    PageNavigator().goToAndKeepWithTransition(
      context,
      const CartPage(),
      PageTransitionType.slideFromRight,
    );
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  PageNavigator().goBack(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Category Name
              Expanded(
                child: Text(
                  categoryName,
                  style: AppTextStyles.BUKIDLINK_LOGO.copyWith(fontSize: 28),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Cart Icon with Badge
              CartIconWithBadge(
                onPressed: () => _handleCartPressed(context),
              ),
              const SizedBox(width: 8),

              // Profile Icon
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to profile
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
