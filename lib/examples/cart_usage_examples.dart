// Example: How to integrate Cart functionality in any page

import 'package:flutter/material.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/pages/CartPage.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/widgets/common/CartIconWithBadge.dart';

// EXAMPLE 1: Add item to cart from any page
class ExampleProductCard extends StatelessWidget {
  final Product product;

  const ExampleProductCard({super.key, required this.product});

  void _addToCart(BuildContext context) {
    final cartService = CartService();
    
    // Add 1 unit of the product
    cartService.addItem(product, 1);
    
    // Show success message
    SnackBarHelper.showSuccess(
      context,
      'Added ${product.name} to cart',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _addToCart(context),
      child: const Text('Add to Cart'),
    );
  }
}

// EXAMPLE 2: Show cart badge in app bar
class ExampleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExampleAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  void _navigateToCart(BuildContext context) {
    PageNavigator().goToAndKeepWithTransition(
      context,
      const CartPage(),
      PageTransitionType.slideFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('My Page'),
      actions: [
        CartIconWithBadge(
          onPressed: () => _navigateToCart(context),
        ),
      ],
    );
  }
}

// EXAMPLE 3: Listen to cart changes and react
class ExampleCartListener extends StatefulWidget {
  const ExampleCartListener({super.key});

  @override
  State<ExampleCartListener> createState() => _ExampleCartListenerState();
}

class _ExampleCartListenerState extends State<ExampleCartListener> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    // Listen to cart changes
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    // Clean up listener
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    // Called whenever cart changes
    if (mounted) {
      setState(() {
        // UI will rebuild automatically
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Cart Items: ${_cartService.itemCount}'),
        Text('Total: ₱${_cartService.total.toStringAsFixed(2)}'),
      ],
    );
  }
}

// EXAMPLE 4: Check cart status
class ExampleCartStatus extends StatelessWidget {
  const ExampleCartStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Column(
      children: [
        // Check if cart is empty
        if (cartService.isEmpty)
          const Text('Your cart is empty'),
        
        // Check if specific product is in cart
        if (cartService.hasProduct('product-123'))
          const Text('Product already in cart'),
        
        // Get quantity of specific product
        Text('Quantity: ${cartService.getProductQuantity('product-123')}'),
        
        // Show cart summary
        Text('Subtotal: ₱${cartService.subtotal.toStringAsFixed(2)}'),
        Text('Delivery: ₱${cartService.deliveryFee.toStringAsFixed(2)}'),
        Text('Total: ₱${cartService.total.toStringAsFixed(2)}'),
      ],
    );
  }
}

// EXAMPLE 5: Quick add to cart button
class QuickAddButton extends StatelessWidget {
  final Product product;

  const QuickAddButton({super.key, required this.product});

  void _quickAdd(BuildContext context) {
    final cartService = CartService();
    
    if (cartService.hasProduct(product.id)) {
      // Product already in cart, increment quantity
      cartService.incrementQuantity(product.id);
      SnackBarHelper.showInfo(
        context,
        'Updated quantity in cart',
      );
    } else {
      // Add new product
      cartService.addItem(product, 1);
      SnackBarHelper.showSuccess(
        context,
        'Added to cart',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      onPressed: () => _quickAdd(context),
    );
  }
}

// EXAMPLE 6: Cart operations
void cartOperationsExample(BuildContext context) {
  final cartService = CartService();
  final product = Product(
    id: '1',
    name: 'Tomatoes',
    farmName: 'Green Valley Farm',
    imagePath: 'assets/images/tomato.png',
    category: 'Vegetables',
    price: 50.0,
  );

  // Add item
  cartService.addItem(product, 2);

  // Get cart item (assuming it's the first item)
  final cartItem = cartService.items.first;

  // Update quantity
  cartService.updateQuantity(cartItem.id, 5);

  // Increment quantity
  cartService.incrementQuantity(cartItem.id); // Now 6

  // Decrement quantity
  cartService.decrementQuantity(cartItem.id); // Now 5

  // Remove specific item
  cartService.removeItem(cartItem.id);

  // Clear entire cart
  cartService.clear();
}

// EXAMPLE 7: Navigate to cart from anywhere
void navigateToCart(BuildContext context) {
  PageNavigator().goToAndKeepWithTransition(
    context,
    const CartPage(),
    PageTransitionType.slideFromRight,
  );
}

// EXAMPLE 8: Custom checkout flow
class CustomCheckoutButton extends StatefulWidget {
  const CustomCheckoutButton({super.key});

  @override
  State<CustomCheckoutButton> createState() => _CustomCheckoutButtonState();
}

class _CustomCheckoutButtonState extends State<CustomCheckoutButton> {
  final CartService _cartService = CartService();
  bool _isProcessing = false;

  Future<void> _checkout() async {
    if (_cartService.isEmpty) {
      SnackBarHelper.showWarning(context, 'Cart is empty');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Success
      SnackBarHelper.showSuccess(
        context,
        'Order placed! Total: ₱${_cartService.total.toStringAsFixed(2)}',
      );

      // Clear cart after successful checkout
      _cartService.clear();

      // Navigate to order confirmation
      // PageNavigator().goTo(context, OrderConfirmationPage());

    } catch (e) {
      if (!mounted) return;
      
      SnackBarHelper.showError(context, 'Checkout failed. Try again.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _checkout,
      child: _isProcessing
          ? const CircularProgressIndicator()
          : const Text('Checkout'),
    );
  }
}
