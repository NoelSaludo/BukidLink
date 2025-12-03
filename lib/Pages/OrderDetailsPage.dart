import 'package:flutter/material.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';
import 'package:bukidlink/pages/CancelOrderPage.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  final FarmerSubStatus? farmerStage;

  const OrderDetailsPage({super.key, required this.order, this.farmerStage});

  (String message, IconData icon, Color color) _getStatusInfo() {
    if (farmerStage != null) {
      switch (farmerStage!) {
        case FarmerSubStatus.pending:
          return ('Waiting for seller approval', Icons.access_time, Colors.orange);
        case FarmerSubStatus.toPack:
          return ('Seller is preparing your order', Icons.inventory_2, Colors.blue);
        case FarmerSubStatus.toHandover:
          return ('Seller is handing over to courier', Icons.local_shipping, Colors.purple);
        case FarmerSubStatus.shipping:
          return ('Your order is on the way!', Icons.local_shipping_outlined, Colors.teal);
        case FarmerSubStatus.completed:
          final deliveredDate = order.dateDelivered != null
              ? _formatDate(order.dateDelivered!)
              : _formatDate(order.datePlaced);
          return ('Delivered on $deliveredDate', Icons.check_circle, Colors.green);
      }
    }

    switch (order.status) {
      case OrderStatus.toPay:
        return ('Waiting for seller approval', Icons.access_time, Colors.orange);
      case OrderStatus.toShip:
        return ('Seller is preparing your order', Icons.inventory_2, Colors.blue);
      case OrderStatus.toReceive:
        return ('Package is in transit', Icons.local_shipping_outlined, Colors.teal);
      case OrderStatus.cancelled:
        return ('Order cancelled', Icons.cancel, Colors.red);
      case OrderStatus.completed:
        final deliveredDate = order.dateDelivered != null
            ? _formatDate(order.dateDelivered!)
            : _formatDate(order.datePlaced);
        return ('Delivered on $deliveredDate', Icons.check_circle, Colors.green);
      default:
        return ('', Icons.help_outline, Colors.grey);
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return 'To Pay';
      case OrderStatus.toShip:
        return 'To Ship';
      case OrderStatus.toReceive:
        return 'To Receive';
      case OrderStatus.toRate:
        return 'To Rate';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return Colors.orange;
      case OrderStatus.toShip:
        return Colors.blue;
      case OrderStatus.toReceive:
        return Colors.purple;
      case OrderStatus.toRate:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  double get subtotal => order.total - 50.0;
  double get shippingFee => 50.0;
  double get total => order.total;

  @override
  Widget build(BuildContext context) {
    final (statusMessage, statusIcon, statusColor) = _getStatusInfo();

    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Order Details', style: AppTextStyles.PRODUCT_INFO_TITLE),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Order Status"),
            _buildStatusCard(statusMessage, statusIcon, statusColor),
            const SizedBox(height: 16),
            _buildSectionTitle("Shipping Information"),
            _buildShippingInfo(),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Summary"),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildSectionTitle("Logistics Status"),
            _buildLogisticsStatus(),
            const SizedBox(height: 16),
            _buildSectionTitle("Payment Method"),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Total"),
            _buildTotalCard(),

            // Cancel Order Button
            if (order.canBeCancelledByCustomer) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CancelOrderPage(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade400, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],

            // Show cancellation details if cancelled
            if (order.status == OrderStatus.cancelled) ...[
              const SizedBox(height: 16),
              _buildSectionTitle("Cancellation Details"),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _whiteBoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Cancelled By', order.cancelledBy ?? 'Unknown'),
                    if (order.cancellationDate != null)
                      _infoRow('Cancellation Date', _formatDate(order.cancellationDate!)),
                    if (order.cancellationReason != null)
                      _infoRow('Reason', order.cancellationReason!),
                    if (order.cancellationComment != null &&
                        order.cancellationComment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Additional Comments:',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.cancellationComment!,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  Widget _buildStatusCard(String message, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusLabel(order.status),
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
          _infoRow("Recipient Name", order.recipientName),
          _infoRow("Contact Number", order.contactNumber),
          _infoRow("Shipping Address", order.shippingAddress),
          const SizedBox(height: 8),
          _infoRow("Order ID", order.id),
          _infoRow("Date Placed", _formatDate(order.datePlaced)),
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

  Widget _buildOrderItems() {
    final Map<String, List<dynamic>> groupedItems = {};
    for (var item in order.items) {
      if (item.product == null) continue;
      final farm = item.product!.farmName;
      groupedItems.putIfAbsent(farm, () => []).add(item);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedItems.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: AppTextStyles.CHECKOUT_SHOP_NAME),
              const SizedBox(height: 8),
              ...entry.value.map((item) => _buildProductRow(item)).toList(),
              if (entry.key != groupedItems.keys.last)
                const Divider(height: 24, thickness: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductRow(dynamic item) {
    if (item.product == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Product information unavailable',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ProductImage(
              imagePath: item.product!.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product!.name, style: AppTextStyles.CHECKOUT_PRODUCT_NAME),
                Text(
                  "x${item.amount} ${item.product!.unit ?? ''}",
                  style: AppTextStyles.CHECKOUT_PRODUCT_DETAILS,
                ),
              ],
            ),
          ),
          PesoText(
            amount: item.totalPrice,
            style: AppTextStyles.CHECKOUT_PRICE,
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsStatus() {
    final statuses = [
      OrderStatus.toPay,
      OrderStatus.toShip,
      OrderStatus.toReceive,
      OrderStatus.toRate,
      OrderStatus.completed,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statuses.map((status) {
          final isCompleted = statuses.indexOf(status) <= statuses.indexOf(order.status);
          final isCurrent = status == order.status;

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.primaryGreen : Colors.grey[300],
                      border: Border.all(
                        color: isCurrent ? AppColors.primaryGreen : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                  if (status != statuses.last)
                    Container(
                      width: 2,
                      height: 30,
                      color: isCompleted ? AppColors.primaryGreen : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cash on Delivery',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          Text(
            label,
            style: isBold
                ? AppTextStyles.CHECKOUT_TOTAL_LABEL
                : AppTextStyles.CHECKOUT_LABEL,
          ),
          PesoText(
            amount: value,
            style: isBold
                ? AppTextStyles.CHECKOUT_TOTAL_VALUE
                : AppTextStyles.CHECKOUT_VALUE,
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}