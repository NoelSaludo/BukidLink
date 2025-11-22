import 'package:flutter/material.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/cart/CartAppBar.dart';
import 'package:bukidlink/widgets/cart/CartItemCard.dart';
import 'package:bukidlink/widgets/cart/CartSummaryCard.dart';
import 'package:bukidlink/widgets/cart/EmptyCartWidget.dart';
import 'package:bukidlink/pages/CheckoutPage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _isProcessing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);
    try {
      await _cartService.loadCart();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _handleQuantityChanged(String productId, int newQuantity) async {
    setState(() => _isProcessing = true);
    try {
      await _cartService.updateProductAmount(productId, newQuantity);
      if (newQuantity == 0) {
        SnackBarHelper.showInfo(context, 'Item removed from cart');
      }
    } catch (e) {
      SnackBarHelper.showError(context, 'Failed to update quantity');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleRemoveItem(String productId) async {
    final item = _cartService.getItem(productId);
    setState(() => _isProcessing = true);
    try {
      await _cartService.removeProductFromCart(productId);
      if (item != null && item.product != null) {
        SnackBarHelper.showInfo(context, '${item.product!.name} removed from cart');
      }
    } catch (e) {
      SnackBarHelper.showError(context, 'Failed to remove item');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleCheckout() async {
    if (_cartService.isEmpty) {
      SnackBarHelper.showWarning(context, 'Your cart is empty');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          cartItems: _cartService.items,
          recipientName: 'Juan Dela Cruz',
          contactNumber: '09123456789',
          shippingAddress: 'Purok 5, Barangay Maligaya, Bukidnon',
        ),
      ),
    );

    if (result == true) {
      await _cartService.clearCart();
      if (mounted) {
        setState(() {});
        SnackBarHelper.showSuccess(context, 'Order placed successfully!');
      }
    }
  }

  void _handleStartShopping() {
    PageNavigator().goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.APP_BACKGROUND,
        appBar: CartAppBar(
          onBackPressed: () => PageNavigator().goBack(context),
          itemCount: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                    _handleQuantityChanged(cartItem.productId, newQuantity),
                onRemove: () => _handleRemoveItem(cartItem.productId),
              );
            },
          ),
        ),
      ],
    );
  }
}
