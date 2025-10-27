import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/productinfo/ReviewItem.dart';

class ProductReviewsSection extends StatelessWidget {
  final List<ProductReview> reviews;
  final VoidCallback? onViewAll;

  const ProductReviewsSection({
    super.key,
    required this.reviews,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
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
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No reviews yet',
              style: AppTextStyles.EMPTY_STATE_TITLE,
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to review this product',
              style: AppTextStyles.EMPTY_STATE_SUBTITLE,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final displayReviews = reviews.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Reviews',
                  style: AppTextStyles.SECTION_TITLE,
                ),
                if (reviews.length > 3 && onViewAll != null)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onViewAll!();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ACCENT_LIME.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View All (${reviews.length})',
                            style: AppTextStyles.LINK_TEXT,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.HEADER_GRADIENT_START,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: displayReviews.length,
            separatorBuilder: (context, index) => Divider(
              height: 32,
              color: AppColors.INACTIVE_GREY.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final review = displayReviews[index];
              return ReviewItem(review: review);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
