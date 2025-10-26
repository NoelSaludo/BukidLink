import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class ProductHeaderWithQuantity extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  static const int _minQuantity = 1;
  static const int _maxQuantity = 99;
  static const double _containerBorderRadius = 20.0;
  static const double _badgeBorderRadius = 8.0;
  static const double _quantityButtonBorderRadius = 12.0;
  static const double _iconSize = 20.0;
  static const double _starIconSize = 18.0;

  const ProductHeaderWithQuantity({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  void _incrementQuantity() {
    if (quantity < _maxQuantity) {
      HapticFeedback.lightImpact();
      onQuantityChanged(quantity + 1);
    }
  }

  void _decrementQuantity() {
    if (quantity > _minQuantity) {
      HapticFeedback.lightImpact();
      onQuantityChanged(quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(_containerBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameAndQuantityRow(),
          const SizedBox(height: 12),
          _buildCategoryBadge(),
          const SizedBox(height: 12),
          if (product.rating != null) ...[
            _buildRatingRow(),
            const SizedBox(height: 12),
          ],
          _buildSellerAndAvailabilityRow(),
        ],
      ),
    );
  }

  Widget _buildNameAndQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(product.name, style: AppTextStyles.PRODUCT_NAME_LARGE),
        ),
        const SizedBox(width: 12),
        _buildQuantitySelector(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(_quantityButtonBorderRadius),
        border: Border.all(
          color: AppColors.ACCENT_LIME.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: _decrementQuantity,
            enabled: quantity > _minQuantity,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: AppTextStyles.QUANTITY_TEXT,
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: _incrementQuantity,
            enabled: quantity < _maxQuantity,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
      ),
      child: Text(product.category, style: AppTextStyles.CATEGORY_BADGE_SMALL),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < (product.rating ?? 0).floor()
                  ? Icons.star
                  : Icons.star_border,
              size: _starIconSize,
              color: AppColors.STAR_RATING,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          product.rating!.toStringAsFixed(1),
          style: AppTextStyles.RATING_TEXT,
        ),
        if (product.reviewCount != null)
          Text(' (${product.reviewCount})', style: AppTextStyles.REVIEW_COUNT),
      ],
    );
  }

  Widget _buildSellerAndAvailabilityRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(_badgeBorderRadius),
          ),
          child: Icon(Icons.store, size: 16, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sold by', style: AppTextStyles.SELLER_LABEL),
            Text(product.farmName, style: AppTextStyles.SELLER_NAME),
          ],
        ),
        const Spacer(),
        _buildAvailabilityBadge(),
      ],
    );
  }

  Widget _buildAvailabilityBadge() {
    final availability = product.availability ?? 'In Stock';
    final color = _getAvailabilityColor(availability);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
      ),
      child: Row(
        children: [
          Icon(_getAvailabilityIcon(availability), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            availability,
            style: AppTextStyles.AVAILABILITY_TEXT.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability.toLowerCase()) {
      case 'in stock':
        return AppColors.SUCCESS_GREEN;
      case 'limited':
        return AppColors.WARNING_ORANGE;
      case 'out of stock':
        return AppColors.ERROR_RED;
      default:
        return AppColors.SUCCESS_GREEN;
    }
  }

  IconData _getAvailabilityIcon(String availability) {
    switch (availability.toLowerCase()) {
      case 'in stock':
        return Icons.check_circle;
      case 'limited':
        return Icons.warning;
      case 'out of stock':
        return Icons.cancel;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(_badgeBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: _iconSize,
          color: enabled ? AppColors.DARK_TEXT : AppColors.HINT_TEXT_GREY,
        ),
      ),
    );
  }
}
