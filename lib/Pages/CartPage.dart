import 'package:flutter/material.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/cart/CartAppBar.dart';
import 'package:bukidlink/widgets/cart/CartItemCard.dart';
import 'package:bukidlink/widgets/cart/CartSummaryCard.dart';
import 'package:bukidlink/widgets/cart/EmptyCartWidget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleQuantityChanged(String cartItemId, int newQuantity) {
    _cartService.updateQuantity(cartItemId, newQuantity);

    if (newQuantity == 0) {
      SnackBarHelper.showInfo(
        context,
        'Item removed from cart',
      );
    }
  }

  void _handleRemoveItem(String cartItemId) {
    final item = _cartService.getItem(cartItemId);
    _cartService.removeItem(cartItemId);

    if (item != null) {
      SnackBarHelper.showInfo(
        context,
        '${item.product.name} removed from cart',
      );
    }
  }

  void _handleCheckout() async {
    if (_cartService.isEmpty) {
      SnackBarHelper.showWarning(context, 'Your cart is empty');
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate checkout processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    SnackBarHelper.showSuccess(
      context,
      'Order placed successfully! Total: ₱${_cartService.total.toStringAsFixed(2)}',
    );

    // TODO: Navigate to order confirmation page
    // For now, clear the cart
    _cartService.clear();
  }

  void _handleStartShopping() {
    PageNavigator().goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: CartAppBar(
        onBackPressed: () => PageNavigator().goBack(context),
        itemCount: _cartService.itemCount,
      ),
      body: _cartService.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cartService.isEmpty
          ? null
          : CartSummaryCard(
              subtotal: _cartService.subtotal,
              deliveryFee: _cartService.deliveryFee,
              total: _cartService.total,
              onCheckout: _handleCheckout,
              isProcessing: _isProcessing,
            ),
    );
  }

  Widget _buildEmptyCart() {
    return EmptyCartWidget(onStartShopping: _handleStartShopping);
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartService.items.length,
            itemBuilder: (context, index) {
              final cartItem = _cartService.items[index];
              return CartItemCard(
                cartItem: cartItem,
                onQuantityChanged: (newQuantity) =>
                    _handleQuantityChanged(cartItem.id, newQuantity),
                onRemove: () => _handleRemoveItem(cartItem.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
