import 'package:flutter/material.dart';
import 'package:bukidlink/models/Trade.dart';
import 'package:bukidlink/models/TradeStatus.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/pages/farmer/TradeDetailsPage.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';

class TradeCard extends StatelessWidget {
  final Trade trade;

  const TradeCard({
    Key? key,
    required this.trade
  }) : super(key: key);

  bool get isCurrentUserFarmerA {
    final currentUserId = UserService.currentUser?.id ?? '';
    return trade.farmerAId == currentUserId;
  }

  String get otherFarmerName {
    return isCurrentUserFarmerA ? trade.farmerBName : trade.farmerAName;
  }

  TradeItem get myItem {
    return isCurrentUserFarmerA ? trade.farmerAItem : trade.farmerBItem;
  }

  TradeItem get theirItem {
    return isCurrentUserFarmerA ? trade.farmerBItem : trade.farmerAItem;
  }

  Color _getStatusColor() {
    switch (trade.status) {
      case TradeStatus.awaitingDeliveryMethod:
      case TradeStatus.awaitingMeetupDetails:
      case TradeStatus.meetupScheduled:
        return Colors.orange;
      case TradeStatus.deliveryMethodConflict:
        return Colors.red;
      case TradeStatus.readyToProceed:
      case TradeStatus.inProgress:
      case TradeStatus.bothShipping:
        return Colors.blue;
      case TradeStatus.onePartyShipped:
        return Colors.purple;
      case TradeStatus.awaitingMutualConfirmation:
        return Colors.teal;
      case TradeStatus.completed:
        return Colors.green;
      case TradeStatus.cancelled:
      case TradeStatus.expired:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (trade.status) {
      case TradeStatus.awaitingDeliveryMethod:
        return isCurrentUserFarmerA ? 'Awaiting Response' : 'Choose Delivery';
      case TradeStatus.deliveryMethodConflict:
        return isCurrentUserFarmerA ? 'Change Requested' : 'Awaiting Response';
      case TradeStatus.awaitingMeetupDetails:
        return isCurrentUserFarmerA ? 'Set Meetup' : 'Awaiting Details';
      case TradeStatus.meetupScheduled:
        return isCurrentUserFarmerA ? 'Awaiting Confirm' : 'Confirm Meetup';
      case TradeStatus.readyToProceed:
        return 'Ready to Proceed';
      case TradeStatus.inProgress:
        return 'In Progress';
      case TradeStatus.onePartyShipped:
        final myShippingStatus = isCurrentUserFarmerA
            ? trade.farmerAShippingStatus
            : trade.farmerBShippingStatus;
        if (myShippingStatus == ShippingStatus.notStarted ||
            myShippingStatus == ShippingStatus.packing ||
            myShippingStatus == ShippingStatus.packed) {
          return 'Ship Within 24hrs';
        }
        return 'Other Party Shipping';
      case TradeStatus.bothShipping:
        return 'Both Shipping';
      case TradeStatus.awaitingMutualConfirmation:
        final myConfirmed = isCurrentUserFarmerA
            ? trade.farmerAConfirmedComplete
            : trade.farmerBConfirmedComplete;
        return myConfirmed ? 'Awaiting Confirm' : 'Confirm Complete';
      case TradeStatus.completed:
        return 'Completed';
      case TradeStatus.cancelled:
        return 'Cancelled';
      case TradeStatus.expired:
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = trade.status == TradeStatus.cancelled || trade.status == TradeStatus.expired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TradeDetailsPage(tradeId: trade.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Trade ID and Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Trade #${trade.id.substring(0, 8)}',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _getStatusColor(),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Trade Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(trade.createdAt),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Trading Partner
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Trading with $otherFarmerName',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Delivery Method (if agreed)
                  if (trade.deliveryMethodStatus == DeliveryMethodStatus.agreed) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          trade.deliveryMethod == DeliveryMethod.shipping
                              ? Icons.local_shipping
                              : Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          trade.deliveryMethod == DeliveryMethod.shipping
                              ? 'Shipping'
                              : 'Meetup',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Trade Items
                  const Text(
                    'Trade Details:',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // You Give
                  _buildItemRow(
                    label: 'You Give',
                    item: myItem,
                    labelColor: Colors.red.shade700,
                  ),
                  const SizedBox(height: 8),

                  // You Get
                  _buildItemRow(
                    label: 'You Get',
                    item: theirItem,
                    labelColor: Colors.green.shade700,
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Cancellation/Expiration info if applicable
                  if (isCancelled) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trade.status == TradeStatus.expired
                                      ? 'Trade Expired'
                                      : 'Cancelled by ${trade.cancelledBy ?? "unknown"}',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                if (trade.cancellationReason != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    trade.cancellationReason!,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Action Hint
                    Row(
                      children: [
                        Icon(Icons.touch_app, size: 14, color: AppColors.primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to manage trade',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required String label,
    required TradeItem item,
    required Color labelColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),

        // Item Details
        Expanded(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ProductImage(
                  imagePath: item.imageUrl,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Qty: ${item.itemQuantity}',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}