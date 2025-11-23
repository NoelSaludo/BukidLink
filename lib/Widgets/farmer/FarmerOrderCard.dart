// FarmerOrderCard.dart
import 'package:flutter/material.dart';
import 'package:bukidlink/data/TestOrdersData.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/pages/farmer/FarmerOrderDetailsPage.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class FarmerOrderCard extends StatelessWidget {
  final FarmerOrder orderWrapper;

  const FarmerOrderCard({super.key, required this.orderWrapper});

  void _updateOrderStatus(BuildContext context, FarmerSubStatus newStatus) {
    orderWrapper.farmerStage = newStatus;
    // Simulate API call here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${_getStatusLabel(newStatus)}!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
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
      default:
        return status.name;
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = orderWrapper;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FarmerOrderDetailsPage(farmerOrder: order),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primaryGreen.withOpacity(0.1),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Farm name and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.farmerName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.farmerStage),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(order.farmerStage),
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
              const SizedBox(height: 12),

              // Order ID
              Text(
                'Order ID: ${order.orderId}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Items list
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item.product.imagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Product details
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
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${item.product.price.toStringAsFixed(2)} each',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Qty: ${item.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              const Divider(height: 24, thickness: 1),

              // Total and recipient info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.recipientName,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.contactNumber,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Total: ₱${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Details button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FarmerOrderDetailsPage(farmerOrder: order),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Stage-specific action button
                  if (order.farmerStage == FarmerSubStatus.pending)
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(context, FarmerSubStatus.toPack),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Accept Order',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (order.farmerStage == FarmerSubStatus.toPack)
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(context, FarmerSubStatus.toHandover),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Mark as Packed',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (order.farmerStage == FarmerSubStatus.toHandover)
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(context, FarmerSubStatus.shipping),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Handover',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}