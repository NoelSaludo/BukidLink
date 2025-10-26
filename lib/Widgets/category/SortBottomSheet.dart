import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'label': 'Popular', 'icon': Icons.trending_up},
      {'label': 'Price: Low to High', 'icon': Icons.arrow_upward},
      {'label': 'Price: High to Low', 'icon': Icons.arrow_downward},
      {'label': 'Name: A-Z', 'icon': Icons.sort_by_alpha},
      {'label': 'Name: Z-A', 'icon': Icons.sort_by_alpha},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.BORDER_GREY.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort By',
                    style: AppTextStyles.productName.copyWith(fontSize: 22),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.DARK_TEXT,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Sort options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortOptions.length,
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                final isSelected = currentSort == option['label'];

                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSortSelected(option['label'] as String);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.TEXT_SECONDARY,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option['label'] as String,
                            style: AppTextStyles.FORM_LABEL.copyWith(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.DARK_TEXT,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
