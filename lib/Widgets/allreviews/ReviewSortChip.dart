import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewSortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReviewSortChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ACCENT_LIME.withValues(alpha: 0.3)
              : AppColors.CARD_BACKGROUND,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.HEADER_GRADIENT_START
                : AppColors.INACTIVE_GREY.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.PRODUCT_CATEGORY.copyWith(
            color: isSelected
                ? AppColors.HEADER_GRADIENT_START
                : AppColors.TEXT_SECONDARY,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
