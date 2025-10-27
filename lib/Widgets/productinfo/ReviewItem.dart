import 'package:flutter/material.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ReviewItem extends StatelessWidget {
  final ProductReview review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.HEADER_GRADIENT_START,
                    AppColors.HEADER_GRADIENT_END,
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(21)),
              ),
              child: Center(
                child: Text(
                  review.userAvatar,
                  style: AppTextStyles.USER_AVATAR_TEXT,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.userName,
                        style: AppTextStyles.REVIEW_USER_NAME,
                      ),
                      if (review.isVerifiedPurchase) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.SUCCESS_GREEN.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.SUCCESS_GREEN.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                size: 10,
                                color: AppColors.SUCCESS_GREEN,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: AppTextStyles.VERIFIED_BADGE,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : index < review.rating
                                ? Icons.star_half
                                : Icons.star_border,
                            color: AppColors.STAR_RATING,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(review.date, style: AppTextStyles.REVIEW_DATE),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(review.comment, style: AppTextStyles.REVIEW_COMMENT),
      ],
    );
  }
}
