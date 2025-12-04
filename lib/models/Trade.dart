import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/models/TradeStatus.dart';

class TradeItem {
  final String listingId;
  final String itemName;
  final String itemQuantity;
  final String itemDescription;
  final String imageUrl;
  final List<String> preferredTrades;

  TradeItem({
    required this.listingId,
    required this.itemName,
    required this.itemQuantity,
    required this.itemDescription,
    required this.imageUrl,
    this.preferredTrades = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'listing_id': listingId,
      'item_name': itemName,
      'item_quantity': itemQuantity,
      'item_description': itemDescription,
      'image_url': imageUrl,
      'preferred_trades': preferredTrades,
    };
  }

  factory TradeItem.fromMap(Map<String, dynamic> map) {
    return TradeItem(
      listingId: map['listing_id'] ?? '',
      itemName: map['item_name'] ?? '',
      itemQuantity: map['item_quantity'] ?? '',
      itemDescription: map['item_description'] ?? '',
      imageUrl: map['image_url'] ?? '',
      preferredTrades: List<String>.from(map['preferred_trades'] ?? []),
    );
  }

  factory TradeItem.fromTradeListing(dynamic tradeListing) {
    return TradeItem(
      listingId: tradeListing.id,
      itemName: tradeListing.name,
      itemQuantity: tradeListing.quantity,
      itemDescription: tradeListing.description,
      imageUrl: tradeListing.image,
      preferredTrades: tradeListing.preferredTrades,
    );
  }

  factory TradeItem.fromTradeOfferRequest(dynamic offerRequest) {
    return TradeItem(
      listingId: offerRequest.listingId,
      itemName: offerRequest.itemName,
      itemQuantity: offerRequest.itemQuantity,
      itemDescription: '',
      imageUrl: offerRequest.imagePath,
      preferredTrades: [],
    );
  }
}

class Trade {
  final String id;
  final String? offerRequestId;
  final String? listingId;

  // Parties
  final String farmerAId;
  final String farmerAName;
  final String farmerAAddress;
  final String farmerBId;
  final String farmerBName;
  final String farmerBAddress;

  // Items being traded
  final TradeItem farmerAItem;
  final TradeItem farmerBItem;

  // Delivery Method
  final DeliveryMethod deliveryMethod;
  final DeliveryMethodStatus deliveryMethodStatus;
  final String? deliveryChangeRequestedBy;
  final String? deliveryChangeReason;

  // Meetup Details (if meetup)
  final DateTime? meetupDate;
  final String? meetupTime;
  final String? meetupLocation;
  final MeetupStatus? meetupStatus;
  final bool? farmerACheckedIn;
  final bool? farmerBCheckedIn;

  // Shipping Details (if shipping)
  final ShippingStatus farmerAShippingStatus;
  final ShippingStatus farmerBShippingStatus;
  final String? farmerATrackingNumber;
  final String? farmerBTrackingNumber;
  final DateTime? farmerAShippedAt;
  final DateTime? farmerBShippedAt;
  final DateTime? shippingDeadline;
  final bool farmerARequestedExtension;
  final bool farmerBRequestedExtension;

  // Completion
  final bool farmerAConfirmedComplete;
  final bool farmerBConfirmedComplete;
  final DateTime? completedAt;

  // Status
  final TradeStatus status;

  // Cancellation
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  Trade({
    required this.id,
    this.offerRequestId,
    this.listingId,
    required this.farmerAId,
    required this.farmerAName,
    required this.farmerAAddress,
    required this.farmerBId,
    required this.farmerBName,
    required this.farmerBAddress,
    required this.farmerAItem,
    required this.farmerBItem,
    required this.deliveryMethod,
    required this.deliveryMethodStatus,
    this.deliveryChangeRequestedBy,
    this.deliveryChangeReason,
    this.meetupDate,
    this.meetupTime,
    this.meetupLocation,
    this.meetupStatus,
    this.farmerACheckedIn,
    this.farmerBCheckedIn,
    this.farmerAShippingStatus = ShippingStatus.notStarted,
    this.farmerBShippingStatus = ShippingStatus.notStarted,
    this.farmerATrackingNumber,
    this.farmerBTrackingNumber,
    this.farmerAShippedAt,
    this.farmerBShippedAt,
    this.shippingDeadline,
    this.farmerARequestedExtension = false,
    this.farmerBRequestedExtension = false,
    this.farmerAConfirmedComplete = false,
    this.farmerBConfirmedComplete = false,
    this.completedAt,
    required this.status,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper: Map ShippingStatus to Order-like stage names
  String getShippingStageLabel(ShippingStatus status) {
    switch (status) {
      case ShippingStatus.notStarted:
        return 'Pending';
      case ShippingStatus.packing:
        return 'Packing';
      case ShippingStatus.packed:
        return 'Packed';
      case ShippingStatus.handedOver:
        return 'To Handover';
      case ShippingStatus.shipping:
        return 'Shipping';
      case ShippingStatus.delivered:
        return 'Delivered';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'offer_request_id': offerRequestId,
      'listing_id': listingId,
      'farmer_a_id': farmerAId,
      'farmer_a_name': farmerAName,
      'farmer_a_address': farmerAAddress,
      'farmer_b_id': farmerBId,
      'farmer_b_name': farmerBName,
      'farmer_b_address': farmerBAddress,
      'farmer_a_item': farmerAItem.toMap(),
      'farmer_b_item': farmerBItem.toMap(),
      'delivery_method': deliveryMethod.toShortString(),
      'delivery_method_status': deliveryMethodStatus.toShortString(),
      'delivery_change_requested_by': deliveryChangeRequestedBy,
      'delivery_change_reason': deliveryChangeReason,
      'meetup_date': meetupDate != null ? Timestamp.fromDate(meetupDate!) : null,
      'meetup_time': meetupTime,
      'meetup_location': meetupLocation,
      'meetup_status': meetupStatus?.toShortString(),
      'farmer_a_checked_in': farmerACheckedIn,
      'farmer_b_checked_in': farmerBCheckedIn,
      'farmer_a_shipping_status': farmerAShippingStatus.toShortString(),
      'farmer_b_shipping_status': farmerBShippingStatus.toShortString(),
      'farmer_a_tracking_number': farmerATrackingNumber,
      'farmer_b_tracking_number': farmerBTrackingNumber,
      'farmer_a_shipped_at': farmerAShippedAt != null ? Timestamp.fromDate(farmerAShippedAt!) : null,
      'farmer_b_shipped_at': farmerBShippedAt != null ? Timestamp.fromDate(farmerBShippedAt!) : null,
      'shipping_deadline': shippingDeadline != null ? Timestamp.fromDate(shippingDeadline!) : null,
      'farmer_a_requested_extension': farmerARequestedExtension,
      'farmer_b_requested_extension': farmerBRequestedExtension,
      'farmer_a_confirmed_complete': farmerAConfirmedComplete,
      'farmer_b_confirmed_complete': farmerBConfirmedComplete,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'status': status.toShortString(),
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Trade.fromMap(Map<String, dynamic> map, String documentId) {
    return Trade(
      id: documentId,
      offerRequestId: map['offer_request_id'],
      listingId: map['listing_id'],
      farmerAId: map['farmer_a_id'] ?? '',
      farmerAName: map['farmer_a_name'] ?? '',
      farmerAAddress: map['farmer_a_address'] ?? '',
      farmerBId: map['farmer_b_id'] ?? '',
      farmerBName: map['farmer_b_name'] ?? '',
      farmerBAddress: map['farmer_b_address'] ?? '',
      farmerAItem: TradeItem.fromMap(map['farmer_a_item'] ?? {}),
      farmerBItem: TradeItem.fromMap(map['farmer_b_item'] ?? {}),
      deliveryMethod: DeliveryMethodExtension.fromString(
        map['delivery_method'] ?? 'shipping',
      ),
      deliveryMethodStatus: DeliveryMethodStatusExtension.fromString(
        map['delivery_method_status'] ?? 'pending',
      ),
      deliveryChangeRequestedBy: map['delivery_change_requested_by'],
      deliveryChangeReason: map['delivery_change_reason'],
      meetupDate: map['meetup_date'] is Timestamp
          ? (map['meetup_date'] as Timestamp).toDate()
          : null,
      meetupTime: map['meetup_time'],
      meetupLocation: map['meetup_location'],
      meetupStatus: map['meetup_status'] != null
          ? MeetupStatusExtension.fromString(map['meetup_status'])
          : null,
      farmerACheckedIn: map['farmer_a_checked_in'],
      farmerBCheckedIn: map['farmer_b_checked_in'],
      farmerAShippingStatus: ShippingStatusExtension.fromString(
        map['farmer_a_shipping_status'] ?? 'notStarted',
      ),
      farmerBShippingStatus: ShippingStatusExtension.fromString(
        map['farmer_b_shipping_status'] ?? 'notStarted',
      ),
      farmerATrackingNumber: map['farmer_a_tracking_number'],
      farmerBTrackingNumber: map['farmer_b_tracking_number'],
      farmerAShippedAt: map['farmer_a_shipped_at'] is Timestamp
          ? (map['farmer_a_shipped_at'] as Timestamp).toDate()
          : null,
      farmerBShippedAt: map['farmer_b_shipped_at'] is Timestamp
          ? (map['farmer_b_shipped_at'] as Timestamp).toDate()
          : null,
      shippingDeadline: map['shipping_deadline'] is Timestamp
          ? (map['shipping_deadline'] as Timestamp).toDate()
          : null,
      farmerARequestedExtension: map['farmer_a_requested_extension'] ?? false,
      farmerBRequestedExtension: map['farmer_b_requested_extension'] ?? false,
      farmerAConfirmedComplete: map['farmer_a_confirmed_complete'] ?? false,
      farmerBConfirmedComplete: map['farmer_b_confirmed_complete'] ?? false,
      completedAt: map['completed_at'] is Timestamp
          ? (map['completed_at'] as Timestamp).toDate()
          : null,
      status: TradeStatusExtension.fromString(
        map['status'] ?? 'awaitingDeliveryMethod',
      ),
      cancellationReason: map['cancellation_reason'],
      cancelledBy: map['cancelled_by'],
      cancelledAt: map['cancelled_at'] is Timestamp
          ? (map['cancelled_at'] as Timestamp).toDate()
          : null,
      createdAt: (map['created_at'] is Timestamp)
          ? (map['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (map['updated_at'] is Timestamp)
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory Trade.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trade.fromMap(data, doc.id);
  }
}