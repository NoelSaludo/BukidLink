import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/pages/ProductInfoPage.dart';
import 'package:bukidlink/widgets/common/AddToCartDialog.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';

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

  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddToCartDialog(
        product: product,
        onAddToCart: (quantity) {
          if (onAddToCart != null) {
            onAddToCart!();
          } else {
            // Default behavior: add to cart service
            final cartService = CartService();
            cartService.addItem(product, quantity);
            SnackBarHelper.showSuccess(
              context,
              'Added $quantity x ${product.name} to cart',
            );
          }
        },
      ),
    );
  }

  // Helper that decides whether to use a network image or an asset image.
  Widget _buildImage(String path, {double? width, double? height, BoxFit? fit}) {
    if (path.toLowerCase().startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
    );
  }

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
                // Use helper to render network or asset image
                _buildImage(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: PesoText(
                              amount: product.price,
                              decimalPlaces: 0,
                              suffix: '/${product.unit ?? 'kg'}',
                              style: AppTextStyles.PRICE_LARGE,
                            ),
                          ),
                          if (showAddButton) ...[
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showAddToCartDialog(context);
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.HEADER_GRADIENT_END,
                                        AppColors.HEADER_GRADIENT_START,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
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
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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
                  _buildImage(
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
                          PesoText(
                            amount: product.price,
                            decimalPlaces: 0,
                            suffix: '/${product.unit ?? 'kg'}',
                            style: AppTextStyles.PRICE_LARGE,
                          ),
                        ],
                      ),
                    ),
                    if (showAddButton) ...[
                      const SizedBox(width: 8),
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showAddToCartDialog(context);
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
