import 'package:flutter/material.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/widgets/productinfo/ReviewItem.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewListSection extends StatelessWidget {
  final List<ProductReview> reviews;

  const ReviewListSection({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
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
          Text(
            '${reviews.length} ${reviews.length == 1 ? 'Review' : 'Reviews'}',
            style: AppTextStyles.SECTION_TITLE,
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => Divider(
              height: 32,
              color: AppColors.INACTIVE_GREY.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewItem(review: review);
            },
          ),
        ],
      ),
    );
  }
}
