import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewEmptyState extends StatelessWidget {
  final bool isFiltered;

  const ReviewEmptyState({
    super.key,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No reviews found',
              style: AppTextStyles.EMPTY_STATE_TITLE,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'No verified purchases match your criteria'
                  : 'No reviews available',
              style: AppTextStyles.EMPTY_STATE_SUBTITLE,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
