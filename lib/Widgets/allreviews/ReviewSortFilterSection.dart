import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/allreviews/ReviewSortChip.dart';
import 'package:bukidlink/widgets/allreviews/ReviewFilterChip.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewSortFilterSection extends StatelessWidget {
  final String sortBy;
  final bool showVerifiedOnly;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<bool> onFilterChanged;

  const ReviewSortFilterSection({
    super.key,
    required this.sortBy,
    required this.showVerifiedOnly,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sort by:',
                style: AppTextStyles.PRODUCT_CATEGORY,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ReviewSortChip(
                        label: 'Most Recent',
                        isSelected: sortBy == 'recent',
                        onTap: () => onSortChanged('recent'),
                      ),
                      const SizedBox(width: 8),
                      ReviewSortChip(
                        label: 'Highest Rating',
                        isSelected: sortBy == 'rating_high',
                        onTap: () => onSortChanged('rating_high'),
                      ),
                      const SizedBox(width: 8),
                      ReviewSortChip(
                        label: 'Lowest Rating',
                        isSelected: sortBy == 'rating_low',
                        onTap: () => onSortChanged('rating_low'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Filter:',
                style: AppTextStyles.PRODUCT_CATEGORY,
              ),
              const SizedBox(width: 12),
              ReviewFilterChip(
                label: 'Verified Purchases Only',
                isActive: showVerifiedOnly,
                onChanged: onFilterChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
