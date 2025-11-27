import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Product.dart';

class TradeOfferCard extends StatelessWidget {
  final Product myProduct;
  final Product offerProduct;
  final double myQuantity;
  final double offerQuantity;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TradeOfferCard({
    super.key,
    required this.myProduct,
    required this.offerProduct,
    required this.myQuantity,
    required this.offerQuantity,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.ACCENT_LIME.withOpacity(0.3),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Products Row
            Row(
              children: [
                // My Product
                Expanded(
                  child: _buildProductSection(
                    label: 'My Product',
                    product: myProduct,
                    quantity: myQuantity,
                  ),
                ),
                const SizedBox(width: 16),
                // Offer Product
                Expanded(
                  child: _buildProductSection(
                    label: 'Offer',
                    product: offerProduct,
                    quantity: offerQuantity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                // Accept Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAccept();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.ACCENT_LIME,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ACCENT_LIME.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Accept',
                            style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Decline Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDecline();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColors.TEXT_SECONDARY.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.TEXT_SECONDARY,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Decline',
                            style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(
                              color: AppColors.TEXT_SECONDARY,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection({
    required String label,
    required Product product,
    required double quantity,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Product Card
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.backgroundYellow.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.ACCENT_LIME.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.imagePath,
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.ACCENT_LIME.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.ACCENT_LIME,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Product Name
              Text(
                product.name,
                style: AppTextStyles.SELLER_NAME_LARGE.copyWith(
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Quantity
              Text(
                '${quantity.toStringAsFixed(0)} ${product.unit ?? 'Kilo'}',
                style: AppTextStyles.STORE_PRODUCT_INFO_LABEL,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
