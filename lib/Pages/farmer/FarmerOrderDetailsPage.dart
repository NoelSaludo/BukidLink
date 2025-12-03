// FarmerOrderDetailsPage.dart
import 'package:flutter/material.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/pages/farmer/FarmerRejectOrderPage.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';

class FarmerOrderDetailsPage extends StatefulWidget {
  final Order order;

  const FarmerOrderDetailsPage({super.key, required this.order});

  @override
  State<FarmerOrderDetailsPage> createState() => _FarmerOrderDetailsPageState();
}

class _FarmerOrderDetailsPageState extends State<FarmerOrderDetailsPage> {
  late Order order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  Future<void> _updateStage(FarmerSubStatus newStage) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await OrderService.shared.updateFarmerStage(order.id, newStage);

      setState(() {
        order.farmerStage = newStage;
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated to ${_getStatusLabel(newStage)}!')),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order: $e')),
        );
      }
    }
  }

  String _getStatusLabel(FarmerSubStatus status) {
    switch (status) {
      case FarmerSubStatus.pending:
        return 'Pending';
      case FarmerSubStatus.toPack:
        return 'To Pack';
      case FarmerSubStatus.toHandover:
        return 'To Handover';
      case FarmerSubStatus.shipping:
        return 'Shipping';
      case FarmerSubStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(FarmerSubStatus status) {
    switch (status) {
      case FarmerSubStatus.pending:
        return Colors.orange;
      case FarmerSubStatus.toPack:
        return Colors.blue;
      case FarmerSubStatus.toHandover:
        return Colors.purple;
      case FarmerSubStatus.shipping:
        return Colors.teal;
      case FarmerSubStatus.completed:
        return Colors.green;
    }
  }

  double get subtotal => order.items.fold(0, (sum, item) => sum + item.totalPrice);
  double get shippingFee => 50.0;
  double get total => subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Recipient Information"),
            _buildRecipientInfo(),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Summary"),
            _buildOrderItems(),
            const SizedBox(height: 16),
            _buildSectionTitle("Logistics Status"),
            _buildLogisticsStatus(),
            const SizedBox(height: 16),
            _buildSectionTitle("Order Total"),
            _buildTotalCard(),
            const SizedBox(height: 24),

            // Show cancellation details if cancelled
            if (order.status == OrderStatus.cancelled) ...[
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
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (order.status != OrderStatus.cancelled) ...[
              // Reject button for pending orders
              if (order.canBeRejectedByFarmer) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FarmerRejectOrderPage(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text(
                      'Reject Order',
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
                const SizedBox(height: 12),
              ],

              // Accept/Update button
              _buildActionButton(),
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

  Widget _buildRecipientInfo() {
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
    final firstItemWithProduct = order.items.firstWhere(
          (item) => item.product != null,
      orElse: () => order.items.first,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstItemWithProduct.product?.farmName ?? 'Unknown Farm',
            style: AppTextStyles.CHECKOUT_SHOP_NAME,
          ),
          const SizedBox(height: 8),
          Column(
            children: order.items.map((item) => _buildProductRow(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(CartItem item) {
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current Status:", style: AppTextStyles.CHECKOUT_LABEL),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status == OrderStatus.cancelled
                      ? Colors.red
                      : _getStatusColor(order.farmerStage),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status == OrderStatus.cancelled
                      ? 'Cancelled'
                      : _getStatusLabel(order.farmerStage),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (order.status != OrderStatus.cancelled)
            _buildStatusTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      FarmerSubStatus.pending,
      FarmerSubStatus.toPack,
      FarmerSubStatus.toHandover,
      FarmerSubStatus.shipping,
      FarmerSubStatus.completed,
    ];

    return Column(
      children: statuses.map((status) {
        final isCompleted = statuses.indexOf(status) <= statuses.indexOf(order.farmerStage);
        final isCurrent = status == order.farmerStage;

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

  Widget _buildActionButton() {
    FarmerSubStatus? nextStage;
    String? buttonText;

    switch (order.farmerStage) {
      case FarmerSubStatus.pending:
        nextStage = FarmerSubStatus.toPack;
        buttonText = 'Accept Order';
        break;
      case FarmerSubStatus.toPack:
        nextStage = FarmerSubStatus.toHandover;
        buttonText = 'Mark as Packed';
        break;
      case FarmerSubStatus.toHandover:
        nextStage = FarmerSubStatus.shipping;
        buttonText = 'Hand Over to Courier';
        break;
      case FarmerSubStatus.shipping:
        nextStage = FarmerSubStatus.completed;
        buttonText = 'Mark as Delivered';
        break;
      case FarmerSubStatus.completed:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : () => _updateStage(nextStage!),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.HEADER_GRADIENT_START,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isUpdating
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(buttonText, style: AppTextStyles.CHECKOUT_BUTTON_TEXT),
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