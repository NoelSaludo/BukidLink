import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final int itemCount;
  final VoidCallback? onClear;

  const CartAppBar({
    super.key,
    required this.onBackPressed,
    required this.itemCount,
    this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.DARK_TEXT),
        onPressed: onBackPressed,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontFamily: AppTextStyles.FONT_FAMILY,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.DARK_TEXT,
            ),
          ),
          if (itemCount > 0)
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.TEXT_SECONDARY,
              ),
            ),
        ],
      ),
      actions: [
        if (itemCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.ERROR_RED),
            onPressed: () => _showClearCartDialog(context),
            tooltip: 'Clear cart',
          ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear Cart',
          style: TextStyle(
            fontFamily: AppTextStyles.FONT_FAMILY,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontFamily: AppTextStyles.FONT_FAMILY),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                color: AppColors.TEXT_SECONDARY,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onClear != null) onClear!();
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                color: AppColors.ERROR_RED,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
