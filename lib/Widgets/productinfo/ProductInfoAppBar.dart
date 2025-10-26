import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ProductInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final VoidCallback? onCartPressed;

  const ProductInfoAppBar({
    super.key,
    required this.onBackPressed,
    this.onCartPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

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
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            onBackPressed();
          },
        ),
        title: const Text('Details', style: AppTextStyles.PRODUCT_INFO_TITLE),
        centerTitle: true,
        actions: [
          if (onCartPressed != null)
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onCartPressed!();
              },
            ),
        ],
      ),
    );
  }
}
