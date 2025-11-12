import 'package:flutter/material.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  (String message, IconData icon, Color color) _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return ('Waiting for seller approval', Icons.access_time, Colors.orangeAccent);
      case OrderStatus.toShip:
        return ('Seller is preparing your order', Icons.local_shipping, Colors.blueAccent);
      case OrderStatus.toReceive:
        return ('Package is in transit — est. delivery 2-3 days', Icons.local_shipping_outlined, Colors.teal);
      case OrderStatus.completed:
        final deliveredDate = order.dateDelivered != null
            ? order.dateDelivered!.toLocal().toString().split(' ')[0]
            : order.datePlaced.toLocal().toString().split(' ')[0];
        return ('Delivered on $deliveredDate', Icons.check_circle, Colors.green);

      default:
        return ('', Icons.help_outline, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusMessage, statusIcon, statusColor) = _getStatusInfo(order.status);

    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.HEADER_GRADIENT_START, AppColors.HEADER_GRADIENT_END],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // STATUS BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusMessage,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SHIPPING DETAILS
            _sectionBox(
              title: 'Shipping Details',
              children: [
                _infoRow('Recipient', order.recipientName),
                _infoRow('Contact', order.contactNumber),
                _infoRow('Address', order.shippingAddress),
              ],
            ),
            const SizedBox(height: 20),

            // ORDER ITEMS
            _sectionBox(
              title: 'Order Items',
              children: order.items
                  .map(
                    (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item.product.imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${item.product.price.toStringAsFixed(2)} x${item.quantity}',
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // PAYMENT METHOD
            _sectionBox(
              title: 'Payment Method',
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.payments, color: Colors.black54),
                  title: Text(
                    'Cash on Delivery',
                    style: TextStyle(fontFamily: 'Outfit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // COMPUTATION
            _sectionBox(
              title: 'Price Summary',
              children: [
                _priceRow('Subtotal', _computeSubtotal(order)),
                _priceRow('Shipping Fee', 50),
                const Divider(),
                _priceRow('Total Payment', order.total, bold: true, highlight: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _computeSubtotal(Order o) => o.total - 50;

  Widget _sectionBox({required String title, required List<Widget> children}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
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

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );

  // 💰 Price Row
  Widget _priceRow(String label, double value, {bool bold = false, bool highlight = false}) {
    final color = highlight ? Colors.green[700] : Colors.black87;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          Text(
            '₱${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: highlight ? 18 : 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
