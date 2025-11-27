import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/cart/CartQuantityControls.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleRemove() async {
    HapticFeedback.mediumImpact();

    await _animationController.forward();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    // Return early if product is null
    if (widget.cartItem.product == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // TODO: Navigate to product detail page
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(),
                  const SizedBox(width: 12),
                  Expanded(child: _buildProductInfo()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = widget.cartItem.product?.imagePath ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        color: AppColors.INACTIVE_GREY,
        child: (() {
          if (imagePath.isEmpty) {
            return const Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppColors.TEXT_SECONDARY,
            );
          }

          final uri = Uri.tryParse(imagePath);
          final isNetwork = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

          if (isNetwork) {
            return Image.network(
              imagePath,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: BouncingDotsLoader(size: 8.0),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 40,
                color: AppColors.TEXT_SECONDARY,
              ),
            );
          }

          // Treat as asset path by default
          return Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 40,
              color: AppColors.TEXT_SECONDARY,
            ),
          );
        })(),
      ),
    );
  }

  Widget _buildProductInfo() {
    final product = widget.cartItem.product!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.FONT_FAMILY,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.DARK_TEXT,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.farmName,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.FONT_FAMILY,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.TEXT_SECONDARY,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _handleRemove,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontFamily: AppTextStyles.FONT_FAMILY,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ERROR_RED,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PesoText(
              amount: product.price,
              decimalPlaces: 2,
              style: const TextStyle(
                fontFamily: AppTextStyles.FONT_FAMILY,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            CartQuantityControls(
              quantity: widget.cartItem.amount,
              onQuantityChanged: widget.onQuantityChanged,
            ),
          ],
        ),
      ],
    );
  }
}
