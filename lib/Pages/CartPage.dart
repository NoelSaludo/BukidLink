import 'package:flutter/material.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/cart/CartAppBar.dart';
import 'package:bukidlink/widgets/cart/CartItemCard.dart';
import 'package:bukidlink/widgets/cart/CartSummaryCard.dart';
import 'package:bukidlink/widgets/cart/EmptyCartWidget.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/models/User.dart' as ModelUser;
import 'package:bukidlink/Pages/CheckOutPage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final cartService = CartService();
  bool loading = true;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    cartService.addListener(_onCartChanged);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      await cartService.loadCart();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _changeQty(String productId, int qty) async {
    setState(() => processing = true);
    try {
      await cartService.updateProductAmount(productId, qty);
      if (qty == 0) SnackBarHelper.showInfo(context, 'Item removed');
    } catch (_) {
      SnackBarHelper.showError(context, 'Failed to update');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> _remove(String productId) async {
    setState(() => processing = true);
    try {
      await cartService.removeProductFromCart(productId);
      SnackBarHelper.showInfo(context, 'Item removed');
    } catch (_) {
      SnackBarHelper.showError(context, 'Failed to remove');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Map<String, String> _recipient(ModelUser.User u) {
    for (final candidate in [u.firstName, u.lastName, u.username, u.emailAddress.split('@').first]) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        return {
          'recipientName': trimmed,
          'contactNumber': u.contactNumber,
          'shippingAddress': u.address,
        };
      }
    }
    return {
      'recipientName': 'Customer',
      'contactNumber': u.contactNumber,
      'shippingAddress': u.address,
    };
  }

  Future<void> _checkout() async {
    if (cartService.isEmpty) { SnackBarHelper.showWarning(context, 'Cart is empty'); return; }
    final u = UserService.currentUser; if (u == null) { SnackBarHelper.showError(context, 'Login required'); return; }
    final info = _recipient(u);
    if (info['contactNumber']!.isEmpty || info['shippingAddress']!.isEmpty) { SnackBarHelper.showWarning(context, 'Complete profile first'); return; }

    // Debug: notify user we're navigating
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening checkout...')));
    debugPrint('[CartPage] Navigating to CheckoutPage with ${cartService.items.length} items');

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          cartItems: cartService.items,
          recipientName: info['recipientName']!,
          contactNumber: info['contactNumber']!,
          shippingAddress: info['shippingAddress']!,
        ),
      ),
    );

    debugPrint('[CartPage] Returned from CheckoutPage with result: $confirmed');

    if (!mounted) return;
    setState(() => processing = true);
    try {
      if (confirmed == true) {
        await cartService.clearCart();
        SnackBarHelper.showSuccess(context, 'Order placed');
      } else {
        SnackBarHelper.showInfo(context, 'Checkout cancelled');
      }
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  void _back() => PageNavigator().goBack(context);

  Future<void> _clearCart() async {
    setState(() => processing = true);
    try {
      await cartService.clearCart();
      SnackBarHelper.showSuccess(context, 'Cart cleared');
    } catch (_) {
      SnackBarHelper.showError(context, 'Failed to clear cart');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.APP_BACKGROUND,
        appBar: CartAppBar(onBackPressed: _back, itemCount: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: CartAppBar(onBackPressed: _back, itemCount: cartService.itemCount, onClear: _clearCart),
      body: cartService.isEmpty ? EmptyCartWidget(onStartShopping: _back) : _list(),
      bottomNavigationBar: cartService.isEmpty ? null : CartSummaryCard(
        subtotal: cartService.subtotal,
        deliveryFee: cartService.deliveryFee,
        total: cartService.total,
        onCheckout: _checkout, // updated to navigate
        isProcessing: processing,
      ),
    );
  }

  Widget _list() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: cartService.items.length,
    itemBuilder: (context, i) {
      final item = cartService.items[i];
      return CartItemCard(
        cartItem: item,
        onQuantityChanged: (q) => _changeQty(item.productId, q),
        onRemove: () => _remove(item.productId),
      );
    },
  );
}
