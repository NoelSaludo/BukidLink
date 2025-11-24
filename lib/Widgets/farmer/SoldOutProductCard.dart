import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';

class SoldOutProductCard extends StatelessWidget {
  final Product product;
  final int soldCount;
  final double rating;
  final double totalEarnings;

  const SoldOutProductCard({
    super.key,
    required this.product,
    required this.soldCount,
    required this.rating,
    required this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.ACCENT_LIME.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductImage(
                imagePath: product.imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Name and Sold Out Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.STORE_PRODUCT_NAME,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.ERROR_RED.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.remove_shopping_cart,
                              size: 12,
                              color: AppColors.ERROR_RED,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sold Out',
                              style: AppTextStyles.CAPTION.copyWith(
                                color: AppColors.ERROR_RED,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Price per unit
                  Text(
                    'Php ${product.price.toStringAsFixed(0)} per ${product.unit ?? 'kilo'}',
                    style: AppTextStyles.STORE_PRODUCT_PRICE,
                  ),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    children: [
                      // Sold Count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sold',
                              style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(
                                fontSize: 11,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              soldCount.toString(),
                              style: AppTextStyles.STORE_PRODUCT_NAME.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate',
                              style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(
                                fontSize: 11,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTextStyles.STORE_PRODUCT_NAME.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Total Earnings
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(
                                fontSize: 11,
                                color: AppColors.TEXT_SECONDARY,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Php ${totalEarnings.toStringAsFixed(0)}',
                              style: AppTextStyles.STORE_PRODUCT_NAME.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
