import 'package:flutter/material.dart';
import 'package:bukidlink/models/Trade.dart';
import 'package:bukidlink/models/TradeStatus.dart';
import 'package:bukidlink/services/TradeManagementService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import 'package:intl/intl.dart';

class TradeDetailsPage extends StatefulWidget {
  final String tradeId;

  const TradeDetailsPage({
    super.key,
    required this.tradeId,
  });

  @override
  State<TradeDetailsPage> createState() => _TradeDetailsPageState();
}

class _TradeDetailsPageState extends State<TradeDetailsPage> {
  final TradeManagementService _tradeService = TradeManagementService();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  DateTime? _selectedMeetupDate;
  bool _isProcessing = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String get _currentUserId => UserService.currentUser?.id ?? '';

  bool _isCurrentUserFarmerA(Trade trade) {
    return trade.farmerAId == _currentUserId;
  }

  String _getOtherFarmerName(Trade trade) {
    return _isCurrentUserFarmerA(trade) ? trade.farmerBName : trade.farmerAName;
  }

  TradeItem _getMyItem(Trade trade) {
    return _isCurrentUserFarmerA(trade) ? trade.farmerAItem : trade.farmerBItem;
  }

  TradeItem _getTheirItem(Trade trade) {
    return _isCurrentUserFarmerA(trade) ? trade.farmerBItem : trade.farmerAItem;
  }

  // DELIVERY METHOD ACTIONS

  Future<void> _handleAgreeToDelivery() async {
    setState(() => _isProcessing = true);
    try {
      await _tradeService.agreeToDeliveryMethod(widget.tradeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery method agreed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRequestChange(Trade trade) async {
    final newMethod = trade.deliveryMethod == DeliveryMethod.shipping
        ? DeliveryMethod.meetup
        : DeliveryMethod.shipping;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Delivery Change', style: TextStyle(fontFamily: 'Outfit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request to change to ${newMethod == DeliveryMethod.shipping ? "Shipping" : "Meetup"}?',
              style: const TextStyle(fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Outfit'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              try {
                setState(() => _isProcessing = true);
                await _tradeService.requestDeliveryChange(
                  widget.tradeId,
                  _reasonController.text,
                  newMethod,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change request sent!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Request', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
    _reasonController.clear();
  }

  Future<void> _handleRespondToChange(bool approve) async {
    setState(() => _isProcessing = true);
    try {
      await _tradeService.respondToDeliveryChange(widget.tradeId, approve);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Change approved!' : 'Change rejected'),
            backgroundColor: approve ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  //  MEETUP ACTIONS

  Future<void> _handleSetMeetupDetails() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Meetup Details', style: TextStyle(fontFamily: 'Outfit')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedMeetupDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(_selectedMeetupDate!),
                  style: const TextStyle(fontFamily: 'Outfit'),
                ),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _selectedMeetupDate = date);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:mm)',
                  hintText: '14:30',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'Outfit'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedMeetupDate == null ||
                  _timeController.text.isEmpty ||
                  _locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              try {
                setState(() => _isProcessing = true);
                await _tradeService.setMeetupDetails(
                  widget.tradeId,
                  _selectedMeetupDate!,
                  _timeController.text,
                  _locationController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meetup details set!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Set', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmMeetup() async {
    setState(() => _isProcessing = true);
    try {
      await _tradeService.confirmMeetupDetails(widget.tradeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meetup confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCheckIn(Trade trade) async {
    setState(() => _isProcessing = true);
    try {
      await _tradeService.checkInToMeetup(widget.tradeId, _currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // SHIPPING ACTIONS

  Future<void> _handleUpdateShippingStatus(
      Trade trade,
      ShippingStatus newStatus,
      ) async {
    String? trackingNumber;

    // Show dialog for tracking number if shipping/handed over
    if (newStatus == ShippingStatus.shipping ||
        newStatus == ShippingStatus.handedOver) {
      trackingNumber = await _showTrackingNumberDialog();
      if (trackingNumber == null) return;
    }

    setState(() => _isProcessing = true);
    try {
      await _tradeService.updateShippingStatus(
        widget.tradeId,
        _currentUserId,
        newStatus,
        trackingNumber: (trackingNumber?.isEmpty ?? true) ? null : trackingNumber,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_getShippingStatusLabel(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String?> _showTrackingNumberDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tracking Number', style: TextStyle(fontFamily: 'Outfit')),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tracking number (optional)',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continue', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
  }

  // COMPLETION

  Future<void> _handleConfirmCompletion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Trade Completion', style: TextStyle(fontFamily: 'Outfit')),
        content: const Text(
          'Are you sure you want to mark this trade as complete? '
              'This action confirms you have received the items as agreed.',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Confirm', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await _tradeService.confirmCompletion(widget.tradeId, _currentUserId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trade completion confirmed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCancelTrade() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trade', style: TextStyle(fontFamily: 'Outfit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to cancel this trade?',
              style: TextStyle(fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Outfit'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(fontFamily: 'Outfit')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              try {
                setState(() => _isProcessing = true);
                await _tradeService.cancelTrade(
                  widget.tradeId,
                  _currentUserId,
                  _reasonController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trade cancelled')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isProcessing = false);
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
    _reasonController.clear();
  }

  // UI HELPERS

  String _getTradeStatusLabel(TradeStatus status) {
    switch (status) {
      case TradeStatus.awaitingDeliveryMethod:
        return 'Awaiting Delivery Method';
      case TradeStatus.deliveryMethodConflict:
        return 'Delivery Method Conflict';
      case TradeStatus.awaitingMeetupDetails:
        return 'Awaiting Meetup Details';
      case TradeStatus.meetupScheduled:
        return 'Meetup Scheduled';
      case TradeStatus.readyToProceed:
        return 'Ready to Proceed';
      case TradeStatus.inProgress:
        return 'In Progress';
      case TradeStatus.onePartyShipped:
        return 'One Party Shipped';
      case TradeStatus.bothShipping:
        return 'Both Shipping';
      case TradeStatus.awaitingMutualConfirmation:
        return 'Awaiting Confirmation';
      case TradeStatus.completed:
        return 'Completed';
      case TradeStatus.cancelled:
        return 'Cancelled';
      case TradeStatus.expired:
        return 'Expired';
    }
  }

  Color _getTradeStatusColor(TradeStatus status) {
    switch (status) {
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
    }
  }

  String _getShippingStatusLabel(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.notStarted:
        return 'Not Started';
      case ShippingStatus.packing:
        return 'Packing';
      case ShippingStatus.packed:
        return 'Packed';
      case ShippingStatus.handedOver:
        return 'Handed to Courier';
      case ShippingStatus.shipping:
        return 'In Transit';
      case ShippingStatus.delivered:
        return 'Delivered';
    }
  }

  Color _getShippingStatusColor(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.notStarted:
        return Colors.grey;
      case ShippingStatus.packing:
      case ShippingStatus.packed:
        return Colors.orange;
      case ShippingStatus.handedOver:
      case ShippingStatus.shipping:
        return Colors.blue;
      case ShippingStatus.delivered:
        return Colors.green;
    }
  }

  Widget _buildActionButtons(Trade trade) {
    final isFarmerA = _isCurrentUserFarmerA(trade);

    // Don't show actions for completed/cancelled/expired trades
    if (trade.status == TradeStatus.completed ||
        trade.status == TradeStatus.cancelled ||
        trade.status == TradeStatus.expired) {
      return const SizedBox.shrink();
    }

    // Delivery Method Agreement
    if (trade.status == TradeStatus.awaitingDeliveryMethod && !isFarmerA) {
      return Column(
        children: [
          _buildButton(
            'Agree to Delivery Method',
            Icons.check,
            _handleAgreeToDelivery,
            AppColors.HEADER_GRADIENT_START,
          ),
          const SizedBox(height: 8),
          _buildOutlinedButton(
            'Request Different Method',
            Icons.swap_horiz,
                () => _handleRequestChange(trade),
            AppColors.primaryGreen,
          ),
        ],
      );
    }

    // Delivery Change Response
    if (trade.status == TradeStatus.deliveryMethodConflict && isFarmerA) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              'Approve',
              Icons.check,
                  () => _handleRespondToChange(true),
              AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildOutlinedButton(
              'Reject',
              Icons.close,
                  () => _handleRespondToChange(false),
              Colors.red,
            ),
          ),
        ],
      );
    }

    // Set Meetup Details
    if (trade.status == TradeStatus.awaitingMeetupDetails && isFarmerA) {
      return _buildButton(
        'Set Meetup Details',
        Icons.location_on,
        _handleSetMeetupDetails,
        AppColors.HEADER_GRADIENT_START,
      );
    }

    // Confirm Meetup
    if (trade.status == TradeStatus.meetupScheduled && !isFarmerA) {
      return _buildButton(
        'Confirm Meetup Details',
        Icons.check,
        _handleConfirmMeetup,
        AppColors.primaryGreen,
      );
    }

    // MEETUP: Check-in button
    if (trade.deliveryMethod == DeliveryMethod.meetup) {
      if (trade.meetupStatus == MeetupStatus.confirmed) {
        final hasCheckedIn = isFarmerA
            ? (trade.farmerACheckedIn ?? false)
            : (trade.farmerBCheckedIn ?? false);

        if (!hasCheckedIn) {
          return _buildButton(
            'Check In to Meetup',
            Icons.location_on,
                () => _handleCheckIn(trade),
            Colors.blue,
          );
        }
      }

      // Show complete button if both checked in
      if (trade.meetupStatus == MeetupStatus.checkedIn ||
          trade.status == TradeStatus.inProgress) {
        final hasConfirmed = isFarmerA
            ? (trade.farmerAConfirmedComplete ?? false)
            : (trade.farmerBConfirmedComplete ?? false);

        if (!hasConfirmed) {
          return _buildButton(
            'Mark as Complete',
            Icons.check_circle,
            _handleConfirmCompletion,
            AppColors.primaryGreen,
          );
        }
      }
    }

    // SHIPPING: Show shipping actions
    if (trade.deliveryMethod == DeliveryMethod.shipping) {
      final myStatus = isFarmerA
          ? trade.farmerAShippingStatus
          : trade.farmerBShippingStatus;

      switch (myStatus) {
        case ShippingStatus.notStarted:
          return _buildButton(
            'Start Packing',
            Icons.inventory,
                () => _handleUpdateShippingStatus(trade, ShippingStatus.packing),
            Colors.orange,
          );

        case ShippingStatus.packing:
          return _buildButton(
            'Mark as Packed',
            Icons.check_box,
                () => _handleUpdateShippingStatus(trade, ShippingStatus.packed),
            Colors.orange,
          );

        case ShippingStatus.packed:
          return Column(
            children: [
              _buildButton(
                'Hand Over to Courier',
                Icons.local_shipping,
                    () => _handleUpdateShippingStatus(trade, ShippingStatus.handedOver),
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildButton(
                'Mark as Shipping',
                Icons.local_shipping,
                    () => _handleUpdateShippingStatus(trade, ShippingStatus.shipping),
                Colors.blue,
              ),
            ],
          );

        case ShippingStatus.handedOver:
        case ShippingStatus.shipping:
          return _buildButton(
            'Order Received',
            Icons.home,
                () => _handleUpdateShippingStatus(trade, ShippingStatus.delivered),
            AppColors.primaryGreen,
          );

        case ShippingStatus.delivered:
          final hasConfirmed = isFarmerA
              ? (trade.farmerAConfirmedComplete ?? false)
              : (trade.farmerBConfirmedComplete ?? false);

          if (!hasConfirmed) {
            return _buildButton(
              'Mark as Complete',
              Icons.check_circle,
              _handleConfirmCompletion,
              AppColors.primaryGreen,
            );
          }
          break;
      }
    }

    // Confirm Completion
    if (trade.status == TradeStatus.awaitingMutualConfirmation) {
      final myConfirmed = isFarmerA
          ? (trade.farmerAConfirmedComplete ?? false)
          : (trade.farmerBConfirmedComplete ?? false);
      if (!myConfirmed) {
        return _buildButton(
          'Confirm Trade Complete',
          Icons.check_circle,
          _handleConfirmCompletion,
          AppColors.primaryGreen,
        );
      }
    }

    // Show waiting message if no action available
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Waiting for other party...',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String label,
      IconData icon,
      VoidCallback onPressed,
      Color color,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : onPressed,
        icon: _isProcessing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(icon),
        label: Text(label, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
      String label,
      IconData icon,
      VoidCallback onPressed,
      Color color,
      ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Trade Details', style: AppTextStyles.PRODUCT_INFO_TITLE),
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
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cancel') {
                  _handleCancelTrade();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel Trade', style: TextStyle(fontFamily: 'Outfit')),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: StreamBuilder<Trade>(
        stream: _tradeService.streamTrade(widget.tradeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Trade not found'));
          }

          final trade = snapshot.data!;
          final isFarmerA = _isCurrentUserFarmerA(trade);
          final myItem = _getMyItem(trade);
          final theirItem = _getTheirItem(trade);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(trade),
                const SizedBox(height: 16),
                _buildPartnerInfo(trade),
                const SizedBox(height: 16),
                _buildTradeItemsCard(trade, myItem, theirItem),
                const SizedBox(height: 16),
                if (trade.deliveryMethodStatus == DeliveryMethodStatus.agreed) ...[
                  _buildDeliveryCard(trade, isFarmerA),
                  const SizedBox(height: 16),
                ],
                if (trade.status == TradeStatus.cancelled || trade.status == TradeStatus.expired) ...[
                  _buildCancellationDetails(trade),
                  const SizedBox(height: 16),
                ],
                _buildActionButtons(trade),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Trade trade) {
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
              Text(
                'Status',
                style: AppTextStyles.CHECKOUT_LABEL.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTradeStatusColor(trade.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTradeStatusLabel(trade.status),
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
          if (trade.deliveryChangeRequestedBy != null &&
              trade.deliveryChangeReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Change Request',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trade.deliveryChangeReason!,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerInfo(Trade trade) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Partner',
            style: AppTextStyles.CHECKOUT_LABEL.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('Trading With', _getOtherFarmerName(trade)),
          _infoRow('Trade ID', trade.id),
          _infoRow('Date Created', _formatDate(trade.createdAt)),
          if (trade.completedAt != null)
            _infoRow('Date Completed', _formatDate(trade.completedAt!)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.CHECKOUT_LABEL,
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.CHECKOUT_VALUE,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeItemsCard(Trade trade, TradeItem myItem, TradeItem theirItem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trade Items',
            style: AppTextStyles.CHECKOUT_LABEL.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildTradeItem('You Give:', myItem, Colors.red.shade700),
          const Divider(height: 32),
          _buildTradeItem('You Get:', theirItem, Colors.green.shade700),
        ],
      ),
    );
  }

  Widget _buildTradeItem(String label, TradeItem item, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.CHECKOUT_LABEL.copyWith(
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImage(
                imagePath: item.imageUrl,
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
                  Text(item.itemName, style: AppTextStyles.CHECKOUT_PRODUCT_NAME),
                  Text(
                    'Quantity: ${item.itemQuantity}',
                    style: AppTextStyles.CHECKOUT_PRODUCT_DETAILS,
                  ),
                  if (item.itemDescription.isNotEmpty)
                    Text(
                      item.itemDescription,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(Trade trade, bool isFarmerA) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                trade.deliveryMethod == DeliveryMethod.shipping
                    ? Icons.local_shipping
                    : Icons.location_on,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                trade.deliveryMethod == DeliveryMethod.shipping ? 'Shipping' : 'Meetup',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (trade.deliveryMethod == DeliveryMethod.meetup) ...[
            _buildMeetupInfo(trade),
          ],

          if (trade.deliveryMethod == DeliveryMethod.shipping) ...[
            _buildShippingInfo(trade, isFarmerA),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetupInfo(Trade trade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trade.meetupDate != null)
          _buildInfoRowWithIcon(
            Icons.calendar_today,
            'Date',
            DateFormat('MMMM dd, yyyy').format(trade.meetupDate!),
          ),
        if (trade.meetupTime != null)
          _buildInfoRowWithIcon(Icons.access_time, 'Time', trade.meetupTime!),
        if (trade.meetupLocation != null)
          _buildInfoRowWithIcon(Icons.location_on, 'Location', trade.meetupLocation!),
        const SizedBox(height: 12),
        Text(
          'Check-in Status:',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCheckInStatus(
                trade.farmerAName,
                trade.farmerACheckedIn ?? false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCheckInStatus(
                trade.farmerBName,
                trade.farmerBCheckedIn ?? false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInStatus(String name, bool checkedIn) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: checkedIn ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checkedIn ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            checkedIn ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: checkedIn ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: checkedIn ? Colors.green[700] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo(Trade trade, bool isFarmerA) {
    final myStatus = isFarmerA
        ? trade.farmerAShippingStatus
        : trade.farmerBShippingStatus;
    final otherStatus = isFarmerA
        ? trade.farmerBShippingStatus
        : trade.farmerAShippingStatus;
    final myTracking = isFarmerA
        ? trade.farmerATrackingNumber
        : trade.farmerBTrackingNumber;
    final otherTracking = isFarmerA
        ? trade.farmerBTrackingNumber
        : trade.farmerATrackingNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Status:',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildShippingStatusRow(myStatus),
        if (myTracking != null) ...[
          const SizedBox(height: 8),
          _buildTrackingInfo(myTracking),
        ],
        const SizedBox(height: 16),
        Text(
          'Their Status:',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildShippingStatusRow(otherStatus),
        if (otherTracking != null) ...[
          const SizedBox(height: 8),
          _buildTrackingInfo(otherTracking),
        ],
        if (trade.shippingDeadline != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deadline: ${DateFormat('MMM dd, yyyy HH:mm').format(trade.shippingDeadline!)}',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShippingStatusRow(ShippingStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getShippingStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getShippingStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getShippingStatusIcon(status),
            size: 16,
            color: _getShippingStatusColor(status),
          ),
          const SizedBox(width: 8),
          Text(
            _getShippingStatusLabel(status),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: _getShippingStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getShippingStatusIcon(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.notStarted:
        return Icons.schedule;
      case ShippingStatus.packing:
        return Icons.inventory;
      case ShippingStatus.packed:
        return Icons.check_box;
      case ShippingStatus.handedOver:
      case ShippingStatus.shipping:
        return Icons.local_shipping;
      case ShippingStatus.delivered:
        return Icons.check_circle;
    }
  }

  Widget _buildTrackingInfo(String trackingNumber) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tracking: $trackingNumber',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationDetails(Trade trade) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation Details',
            style: AppTextStyles.CHECKOUT_LABEL.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            trade.status == TradeStatus.expired ? 'Status' : 'Cancelled By',
            trade.status == TradeStatus.expired ? 'Expired' : (trade.cancelledBy ?? 'Unknown'),
          ),
          if (trade.cancelledAt != null)
            _infoRow('Cancellation Date', _formatDate(trade.cancelledAt!)),
          if (trade.cancellationReason != null)
            _infoRow('Reason', trade.cancellationReason!),
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
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}