import 'package:flutter/material.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewRatingSummary extends StatelessWidget {
  final List<ProductReview> reviews;

  const ReviewRatingSummary({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    final totalReviews = reviews.length;
    final averageRating =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;

    // Count reviews by rating
    final ratingCounts = <int, int>{};
    for (var i = 5; i >= 1; i--) {
      ratingCounts[i] =
          reviews.where((r) => r.rating >= i && r.rating < i + 1).length;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average rating display
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: AppTextStyles.RATING_TEXT_LARGE.copyWith(
                    fontSize: 48,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < averageRating.floor()
                          ? Icons.star
                          : index < averageRating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: AppColors.STAR_RATING,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                  style: AppTextStyles.PRODUCT_CATEGORY,
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Rating distribution
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                final starCount = 5 - index;
                final count = ratingCounts[starCount] ?? 0;
                final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '$starCount',
                        style: AppTextStyles.PRODUCT_CATEGORY.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.STAR_RATING,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.INACTIVE_GREY.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.STAR_RATING,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          style: AppTextStyles.PRODUCT_CATEGORY.copyWith(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
