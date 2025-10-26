import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/pages/ProductInfoPage.dart';

enum ProductCardLayout {
  compact, // Compact layout for recommended products (horizontal scroll)
  grid,   // Grid layout for product grids (vertical scroll)
}

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCardLayout layout;
  final bool showAddButton;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.layout = ProductCardLayout.grid,
    this.showAddButton = false,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        PageNavigator().goToAndKeepWithTransition(
          context,
          ProductInfoPage(product: product),
          PageTransitionType.scaleAndFade,
        );
      },
      child: layout == ProductCardLayout.compact
          ? _buildCompactCard()
          : _buildGridCard(),
    );
  }

  Widget _buildCompactCard() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                Image.asset(
                  product.imagePath,
                  width: 180,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.SELLER_NAME_LARGE,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.farmName,
                        style: AppTextStyles.SELLER_LABEL,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.rating != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.STAR_RATING,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.rating!.toStringAsFixed(1),
                              style: AppTextStyles.CATEGORY_BADGE,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        'PHP ${product.price.toStringAsFixed(0)}/${product.unit ?? 'kg'}',
                        style: AppTextStyles.PRICE_LARGE,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    product.imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.SELLER_NAME_LARGE,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.farmName,
                  style: AppTextStyles.SELLER_LABEL,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.rating != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.STAR_RATING,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: AppTextStyles.CATEGORY_BADGE,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'PHP ${product.price.toStringAsFixed(0)}/${product.unit ?? 'kg'}',
                            style: AppTextStyles.PRICE_LARGE,
                          ),
                        ],
                      ),
                    ),
                    if (showAddButton) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (onAddToCart != null) {
                            onAddToCart!();
                          } else {
                            print("Add ${product.name} to cart");
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.HEADER_GRADIENT_END,
                                AppColors.HEADER_GRADIENT_START,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
