import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';

class ProductHeaderWithQuantity extends StatefulWidget {
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

  @override
  State<ProductHeaderWithQuantity> createState() => _ProductHeaderWithQuantityState();
}

class _ProductHeaderWithQuantityState extends State<ProductHeaderWithQuantity> {
  late TextEditingController _quantityController;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.quantity.toString());
    _quantityFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(ProductHeaderWithQuantity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_quantityFocusNode.hasFocus) {
      _quantityController.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    if (widget.quantity < ProductHeaderWithQuantity._maxQuantity) {
      HapticFeedback.lightImpact();
      widget.onQuantityChanged(widget.quantity + 1);
    }
  }

  void _decrementQuantity() {
    if (widget.quantity > ProductHeaderWithQuantity._minQuantity) {
      HapticFeedback.lightImpact();
      widget.onQuantityChanged(widget.quantity - 1);
    }
  }

  void _handleQuantitySubmit(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      if (newQuantity < ProductHeaderWithQuantity._minQuantity) {
        newQuantity = ProductHeaderWithQuantity._minQuantity;
      } else if (newQuantity > ProductHeaderWithQuantity._maxQuantity) {
        newQuantity = ProductHeaderWithQuantity._maxQuantity;
      }
      widget.onQuantityChanged(newQuantity);
      _quantityController.text = newQuantity.toString();
    } else {
      _quantityController.text = widget.quantity.toString();
    }
    _quantityFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(ProductHeaderWithQuantity._containerBorderRadius),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(widget.product.name, style: AppTextStyles.PRODUCT_NAME_LARGE),
              ),
              const SizedBox(width: 12),
              _buildQuantitySelector(),
            ],
          ),
          const SizedBox(height: 8),
          _buildPricePerUnit(),
          const SizedBox(height: 12),
          _buildCategoryBadge(),
          const SizedBox(height: 12),
          if (widget.product.rating != null) ...[
            _buildRatingRow(),
            const SizedBox(height: 12),
          ],
          _buildAvailabilityBadge(),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(ProductHeaderWithQuantity._quantityButtonBorderRadius),
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
            enabled: widget.quantity > ProductHeaderWithQuantity._minQuantity,
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _quantityController,
              focusNode: _quantityFocusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: AppTextStyles.QUANTITY_TEXT,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onSubmitted: _handleQuantitySubmit,
              onTapOutside: (_) {
                _handleQuantitySubmit(_quantityController.text);
              },
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: _incrementQuantity,
            enabled: widget.quantity < ProductHeaderWithQuantity._maxQuantity,
          ),
        ],
      ),
    );
  }

  Widget _buildPricePerUnit() {
    return Row(
      children: [
        PesoText(
          amount: widget.product.price,
          decimalPlaces: 2,
          style: AppTextStyles.PRODUCT_NAME_LARGE.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        Text(
          ' / ${widget.product.unit}',
          style: AppTextStyles.SELLER_LABEL.copyWith(
            color: AppColors.DARK_TEXT,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ProductHeaderWithQuantity._badgeBorderRadius),
      ),
      child: Text(widget.product.category, style: AppTextStyles.CATEGORY_BADGE_SMALL),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < (widget.product.rating ?? 0).floor()
                  ? Icons.star
                  : Icons.star_border,
              size: ProductHeaderWithQuantity._starIconSize,
              color: AppColors.STAR_RATING,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          widget.product.rating!.toStringAsFixed(1),
          style: AppTextStyles.RATING_TEXT,
        ),
        if (widget.product.reviewCount != null)
          Text(' (${widget.product.reviewCount})', style: AppTextStyles.REVIEW_COUNT),
      ],
    );
  }

  Widget _buildAvailabilityBadge() {
    final availability = widget.product.availability;
    final color = _getAvailabilityColor(availability);
    final stockCount = widget.product.stockCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ProductHeaderWithQuantity._badgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getAvailabilityIcon(availability), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            availability,
            style: AppTextStyles.AVAILABILITY_TEXT.copyWith(color: color),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$stockCount left',
              style: AppTextStyles.AVAILABILITY_TEXT.copyWith(
                color: AppColors.TEXT_SECONDARY,
                fontSize: 10,
              ),
            ),
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
      borderRadius: BorderRadius.circular(ProductHeaderWithQuantity._badgeBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: ProductHeaderWithQuantity._iconSize,
          color: enabled ? AppColors.DARK_TEXT : AppColors.HINT_TEXT_GREY,
        ),
      ),
    );
  }
}
