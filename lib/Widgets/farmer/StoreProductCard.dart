import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';

class StoreProductCard extends StatelessWidget {
  final Product product;
  final int stockSold;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final bool isArchived;

  const StoreProductCard({
    super.key,
    required this.product,
    required this.stockSold,
    this.onEdit,
    this.onRemove,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isArchived ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isArchived
              ? Colors.grey.withOpacity(0.3)
              : AppColors.ACCENT_LIME.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProductImage(
                    imagePath: product.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.STORE_PRODUCT_NAME,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Php ${product.price.toStringAsFixed(0)} per ${product.unit ?? 'kilo'}',
                        style: AppTextStyles.STORE_PRODUCT_PRICE,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: AppColors.ACCENT_LIME.withOpacity(0.2),
          ),
          // Stock and Rating Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                // Stock Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock  ${product.stockCount}',
                        style: AppTextStyles.STORE_PRODUCT_INFO_LABEL,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sold    $stockSold',
                        style: AppTextStyles.STORE_PRODUCT_INFO_LABEL,
                      ),
                    ],
                  ),
                ),
                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Rate',
                      style: AppTextStyles.STORE_PRODUCT_INFO_LABEL,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          if (index < (product.rating ?? 0).floor()) {
                            return const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.STAR_RATING,
                            );
                          } else if (index < (product.rating ?? 0)) {
                            return const Icon(
                              Icons.star_half,
                              size: 16,
                              color: AppColors.STAR_RATING,
                            );
                          } else {
                            return Icon(
                              Icons.star_border,
                              size: 16,
                              color: AppColors.TEXT_SECONDARY,
                            );
                          }
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.rating?.toStringAsFixed(1) ?? '0.0'})',
                          style: AppTextStyles.STORE_PRODUCT_RATING,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onEdit?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColors.DARK_TEXT,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: AppTextStyles.STORE_ACTION_BUTTON,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRemove?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isArchived ? AppColors.HEADER_GRADIENT_START : AppColors.DARK_TEXT,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isArchived)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.restore_from_trash,
                              size: 18,
                              color: AppColors.HEADER_GRADIENT_START,
                            ),
                          ),
                        Text(
                          isArchived ? 'Restore' : 'Remove',
                          style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(
                            color: isArchived ? AppColors.HEADER_GRADIENT_START : AppColors.DARK_TEXT,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
