import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const ReviewFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.SUCCESS_GREEN.withValues(alpha: 0.15)
              : AppColors.CARD_BACKGROUND,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.SUCCESS_GREEN
                : AppColors.INACTIVE_GREY.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isActive
                  ? AppColors.SUCCESS_GREEN
                  : AppColors.TEXT_SECONDARY,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.PRODUCT_CATEGORY.copyWith(
                color: isActive
                    ? AppColors.SUCCESS_GREEN
                    : AppColors.TEXT_SECONDARY,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
