import 'package:flutter/material.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';

class CheckoutPage extends StatelessWidget {
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

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  double get deliveryFee => cartItems.isEmpty ? 0 : 50.0;

  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionBox(
              title: 'Shipping Information',
              children: [
                _infoRow('Recipient', recipientName),
                _infoRow('Contact Number', contactNumber),
                _infoRow('Address', shippingAddress),
              ],
            ),
            const SizedBox(height: 16),

            // Order Items
            _sectionBox(
              title: 'Order Items',
              children: cartItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item.product.imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Payment Method
            _sectionBox(
              title: 'Payment Method',
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.payments_rounded, color: Colors.green),
                  title: Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Computation
            _sectionBox(
              title: 'Order Summary',
              children: [
                _priceRow('Subtotal', subtotal),
                _priceRow('Shipping Fee', deliveryFee),
                const Divider(),
                _priceRow('Total', total, bold: true, highlight: true),
              ],
            ),
            const SizedBox(height: 30),

            // Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, 'Order placed successfully!');
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionBox({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💸 Price breakdown row
  Widget _priceRow(String label, double value,
      {bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₱${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.green[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
