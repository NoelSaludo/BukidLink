import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class AddToCartDialog extends StatefulWidget {
  final Product product;
  final Function(int quantity) onAddToCart;

  const AddToCartDialog({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  static const int _minQuantity = 1;
  static const int _maxQuantity = 99;
  
  int _quantity = _minQuantity;
  late double _totalPrice;
  late TextEditingController _quantityController;
  late FocusNode _quantityFocusNode;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
    _quantityController = TextEditingController(text: _quantity.toString());
    _quantityFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity.clamp(_minQuantity, _maxQuantity);
      _totalPrice = widget.product.price * _quantity;
      if (!_quantityFocusNode.hasFocus) {
        _quantityController.text = _quantity.toString();
      }
    });
  }

  void _incrementQuantity() {
    if (_quantity < _maxQuantity) {
      HapticFeedback.lightImpact();
      _updateQuantity(_quantity + 1);
    }
  }

  void _decrementQuantity() {
    if (_quantity > _minQuantity) {
      HapticFeedback.lightImpact();
      _updateQuantity(_quantity - 1);
    }
  }

  void _handleQuantitySubmit(String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null) {
      _updateQuantity(newQuantity);
    } else {
      _quantityController.text = _quantity.toString();
    }
    _quantityFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.CARD_BACKGROUND,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    widget.product.imagePath,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: AppTextStyles.PRODUCT_NAME_LARGE,
                  ),
                  const SizedBox(height: 4),

                  // Farm Name
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.farmName,
                        style: AppTextStyles.SELLER_LABEL,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price per unit
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ACCENT_LIME.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₱${widget.product.price.toStringAsFixed(2)}',
                          style: AppTextStyles.PRICE_LARGE.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${widget.product.unit}',
                          style: AppTextStyles.SELLER_LABEL,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: AppTextStyles.SELLER_NAME_LARGE,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.CARD_BACKGROUND,
                          borderRadius: BorderRadius.circular(12),
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
                              enabled: _quantity > _minQuantity,
                            ),
                            Container(
                              width: 50,
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
                              enabled: _quantity < _maxQuantity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Divider(
                    color: AppColors.HINT_TEXT_GREY.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: AppTextStyles.SELLER_NAME_LARGE,
                      ),
                      Text(
                        '₱${_totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.PRODUCT_NAME_LARGE.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onAddToCart(_quantity);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.HEADER_GRADIENT_END,
                              AppColors.HEADER_GRADIENT_START,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add to Cart',
                                style: AppTextStyles.BUTTON_TEXT.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.DARK_TEXT : AppColors.HINT_TEXT_GREY,
        ),
      ),
    );
  }
}
