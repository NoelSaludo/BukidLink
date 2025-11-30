//CheckOutPage.dart
import 'package:flutter/material.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String recipientName;
  final String contactNumber;
  final String shippingAddress;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.recipientName,
    required this.contactNumber,
    required this.shippingAddress,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = "Cash on Delivery";
  bool _isPlacing = false;

  double get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  double get shippingFee => 50.0;
  double get total => subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupByFarmName();

    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Checkout', style: AppTextStyles.PRODUCT_INFO_TITLE),
        centerTitle: true,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.HEADER_GRADIENT_START,
                AppColors.HEADER_GRADIENT_END,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Shipping Information"),
            _buildShippingInfo(),
            const SizedBox(height: 16),
            _buildSectionTitle("Payment Method"),
            _buildPaymentMethodSection(),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Summary"),

            if (groupedItems.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your items will be split into ${groupedItems.length} separate orders (one per farm)',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ...groupedItems.entries
                .map((entry) => _buildShopSection(entry.key, entry.value)),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Total"),
            _buildTotalCard(),
            const SizedBox(height: 24),
            _buildPlaceOrderButton(context),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // Section Builders
  // ------------------------------

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.HEADER_GRADIENT_START,
            AppColors.HEADER_GRADIENT_END,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Text(title, style: AppTextStyles.CHECKOUT_SECTION_TITLE),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Recipient Name", widget.recipientName),
          _infoRow("Contact Number", widget.contactNumber),
          _infoRow("Shipping Address", widget.shippingAddress),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Only Cash on Delivery is available for now.")),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundYellow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedPaymentMethod,
                      style: AppTextStyles.CHECKOUT_LABEL),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: AppTextStyles.CHECKOUT_LABEL,
          children: [
            TextSpan(
              text: value,
              style: AppTextStyles.CHECKOUT_VALUE,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopSection(String shopName, List<CartItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _whiteBoxDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shopName, style: AppTextStyles.CHECKOUT_SHOP_NAME),
          const SizedBox(height: 8),
          Column(
            children: items.map((item) => _buildProductRow(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(CartItem item) {
    if (item.product == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildProductImage(item.product!.imagePath),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product!.name,
                    style: AppTextStyles.CHECKOUT_PRODUCT_NAME),
                Text("x${item.amount} ${item.product!.unit ?? ''}",
                    style: AppTextStyles.CHECKOUT_PRODUCT_DETAILS),
              ],
            ),
          ),
          Text("₱${item.totalPrice.toStringAsFixed(2)}",
              style: AppTextStyles.CHECKOUT_PRICE),
        ],
      ),
    );
  }

  Widget _buildProductImage(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final effectivePath = path.isNotEmpty ? path : 'assets/images/default_cover_photo.png';
    if (isNetwork) {
      return Image.network(
        effectivePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_cover_photo.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          );
        },
      );
    }
    // Asset fallback
    return Image.asset(
      effectivePath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalRow("Subtotal", subtotal),
          _totalRow("Shipping Fee", shippingFee),
          const Divider(height: 20, thickness: 1),
          _totalRow("Grand Total", total, isBold: true),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? AppTextStyles.CHECKOUT_TOTAL_LABEL
                  : AppTextStyles.CHECKOUT_LABEL),
          Text("₱${value.toStringAsFixed(2)}",
              style: isBold
                  ? AppTextStyles.CHECKOUT_TOTAL_VALUE
                  : AppTextStyles.CHECKOUT_VALUE),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacing ? null : () async {
          if (widget.cartItems.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cart is empty.')),
            );
            return;
          }

          setState(() => _isPlacing = true);

          try {
            final orderService = OrderService();

            final orderIds = await orderService.addOrdersFromCart(
              items: widget.cartItems,
              recipientName: widget.recipientName,
              contactNumber: widget.contactNumber,
              shippingAddress: widget.shippingAddress,
            );

            if (orderIds.isNotEmpty) {

              final message = orderIds.length == 1
                  ? 'Order placed successfully!'
                  : '${orderIds.length} orders placed successfully!';

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );

                // Return true to signal success (caller should clear cart)
                Navigator.pop(context, true);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to place order. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            debugPrint(' Error placing order: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _isPlacing = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.HEADER_GRADIENT_START,
          disabledBackgroundColor: AppColors.HEADER_GRADIENT_START.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isPlacing
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text("Place Order", style: AppTextStyles.CHECKOUT_BUTTON_TEXT),
      ),
    );
  }

  BoxDecoration _whiteBoxDecoration() {
    return BoxDecoration(
      color: AppColors.containerWhite,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Map<String, List<CartItem>> _groupByFarmName() {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in widget.cartItems) {
      if (item.product == null) continue;
      final key = item.product!.farmName;
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
}