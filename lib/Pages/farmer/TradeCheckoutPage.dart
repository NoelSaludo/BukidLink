import 'package:flutter/material.dart';
import 'package:bukidlink/models/TradeModels.dart';
import 'package:bukidlink/models/Trade.dart';
import 'package:bukidlink/models/TradeStatus.dart';
import 'package:bukidlink/Pages/farmer/TradeDetailsPage.dart';
import 'package:bukidlink/services/TradeManagementService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TradeCheckoutPage extends StatefulWidget {
  final TradeListing listing;
  final TradeOfferRequest offer;

  const TradeCheckoutPage({
    super.key,
    required this.listing,
    required this.offer,
  });

  @override
  State<TradeCheckoutPage> createState() => _TradeCheckoutPageState();
}

class _TradeCheckoutPageState extends State<TradeCheckoutPage> {
  final TradeManagementService _tradeService = TradeManagementService();

  DeliveryMethod _selectedDelivery = DeliveryMethod.shipping;
  DateTime? _selectedMeetupDate;
  TimeOfDay? _selectedMeetupTime;
  final TextEditingController _locationController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  String get _userAddress {
    final user = UserService.currentUser;
    return user?.address ?? 'No address on file';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedMeetupDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedMeetupTime = time);
    }
  }

  Future<void> _handleCreateTrade() async {
    // Validation
    if (_selectedDelivery == DeliveryMethod.meetup) {
      if (_selectedMeetupDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a meetup date')),
        );
        return;
      }
      if (_selectedMeetupTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a meetup time')),
        );
        return;
      }
      if (_locationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a meetup location')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final currentUser = UserService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      print('Creating trade with:');
      print('Offer ID: ${widget.offer.id}');
      print('Listing ID: ${widget.listing.id}');
      print('Farmer A ID: ${widget.listing.farmerId}');
      print('Farmer B ID: ${widget.offer.offeredByUid}');

      // Fetch Farmer B's address from Firestore
      final farmerBDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.offer.offeredByUid)
          .get();
      final farmerBAddress = farmerBDoc.data()?['address'] ?? 'No address on file';

      // Create TradeItem from listing (what Farmer A gives)
      final farmerAItem = TradeItem.fromTradeListing(widget.listing);

      // Create TradeItem from offer (what Farmer B gives)
      final farmerBItem = TradeItem.fromTradeOfferRequest(widget.offer);

      // Create the trade
      final tradeId = await _tradeService.createTradeFromOffer(
        offerRequestId: widget.offer.id,
        listingId: widget.listing.id,
        farmerAId: widget.listing.farmerId,
        farmerAName: '${currentUser.firstName ?? ''} ${currentUser.lastName ?? ''}'.trim(),
        farmerAAddress: currentUser.address ?? 'No address on file',
        farmerBId: widget.offer.offeredByUid,
        farmerBName: widget.offer.offeredByName,
        farmerBAddress: farmerBAddress,
        farmerAItem: farmerAItem,
        farmerBItem: farmerBItem,
        initialDeliveryMethod: _selectedDelivery,
      );

      print('Trade created with ID: $tradeId');

      // If meetup is selected, set the meetup details
      if (_selectedDelivery == DeliveryMethod.meetup) {
        final timeString = '${_selectedMeetupTime!.hour.toString().padLeft(2, '0')}:${_selectedMeetupTime!.minute.toString().padLeft(2, '0')}';

        print('Setting meetup details...');
        await _tradeService.setMeetupDetails(
          tradeId,
          _selectedMeetupDate!,
          timeString,
          _locationController.text.trim(),
        );
        print('Meetup details set');
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trade created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to trade details, replacing all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => TradeDetailsPage(tradeId: tradeId),
          ),
              (route) => route.isFirst,
        );
      }
    } catch (e, stackTrace) {
      print('Error creating trade: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() => _isProcessing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating trade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        title: Text('Trade Checkout', style: AppTextStyles.PRODUCT_INFO_TITLE),
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
            _buildSectionTitle('Trade Details'),
            _buildTradeItems(),
            const SizedBox(height: 20),

            _buildSectionTitle('Delivery Method'),
            _buildDeliveryMethod(),
            const SizedBox(height: 20),

            if (_selectedDelivery == DeliveryMethod.meetup) ...[
              _buildSectionTitle('Meetup Details'),
              _buildMeetupDetails(),
              const SizedBox(height: 20),
            ],

            if (_selectedDelivery == DeliveryMethod.shipping) ...[
              _buildSectionTitle('Shipping Address'),
              _buildShippingAddress(),
              const SizedBox(height: 20),
            ],

            _buildConfirmButton(),
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

  Widget _buildTradeItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerWhite,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You Give:',
            style: AppTextStyles.CHECKOUT_LABEL.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildItemRow(
            widget.listing.image,
            widget.listing.name,
            widget.listing.quantity,
            widget.listing.description,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Text(
            'You Get:',
            style: AppTextStyles.CHECKOUT_LABEL.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildItemRow(
            widget.offer.imagePath,
            widget.offer.itemName,
            widget.offer.itemQuantity,
            '',
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String imagePath, String name, String quantity, String description) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ProductImage(
            imagePath: imagePath.isNotEmpty
                ? imagePath
                : 'assets/images/default_cover_photo.png',
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
              Text(name, style: AppTextStyles.CHECKOUT_PRODUCT_NAME),
              Text(
                'Quantity: $quantity',
                style: AppTextStyles.CHECKOUT_PRODUCT_DETAILS,
              ),
              if (description.isNotEmpty)
                Text(
                  description,
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
    );
  }

  Widget _buildDeliveryMethod() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerWhite,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDeliveryOption(
            DeliveryMethod.shipping,
            'Shipping',
            'Items will be shipped to addresses',
            Icons.local_shipping,
          ),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            DeliveryMethod.meetup,
            'Meetup',
            'Meet in person to exchange items',
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(
      DeliveryMethod method,
      String title,
      String subtitle,
      IconData icon,
      ) {
    final isSelected = _selectedDelivery == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedDelivery = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryGreen : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetupDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerWhite,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule your meetup',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Date Picker
          InkWell(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedMeetupDate == null
                          ? 'Select Date'
                          : DateFormat('MMMM dd, yyyy').format(_selectedMeetupDate!),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        color: _selectedMeetupDate == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Time Picker
          InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedMeetupTime == null
                          ? 'Select Time'
                          : _selectedMeetupTime!.format(context),
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        color: _selectedMeetupTime == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Location Input
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Meetup Location',
              hintText: 'Enter specific location',
              prefixIcon: Icon(Icons.place, color: AppColors.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
              ),
            ),
            style: const TextStyle(fontFamily: 'Outfit'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerWhite,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Your Address',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _userAddress,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items will be shipped to the addresses on file for both parties.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleCreateTrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.HEADER_GRADIENT_START,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isProcessing
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          'Confirm Trade',
          style: AppTextStyles.CHECKOUT_BUTTON_TEXT.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}