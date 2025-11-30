import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  toPay,
  toShip,
  toReceive,
  toRate,
  completed,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final String recipientName;
  final String contactNumber;
  final String shippingAddress;
  final DateTime datePlaced;
  final String farmerId;
  FarmerSubStatus farmerStage;
  DateTime? dateDelivered;
  OrderStatus status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.farmerId,
    required this.farmerStage,
    required this.recipientName,
    required this.contactNumber,
    required this.shippingAddress,
    required this.datePlaced,
    this.dateDelivered,
    required this.status,
  });

  double get total => items.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isAllRated {
    return items.every((item) => (item.product?.rating ?? 0) > 0);
  }

  // ADD: Convert FarmerSubStatus enum to string for Firestore
  static String farmerStageToString(FarmerSubStatus stage) {
    switch (stage) {
      case FarmerSubStatus.pending:
        return 'pending';
      case FarmerSubStatus.toPack:
        return 'to_pack';
      case FarmerSubStatus.toHandover:
        return 'to_handover';
      case FarmerSubStatus.shipping:
        return 'shipping';
      case FarmerSubStatus.completed:
        return 'completed';
    }
  }

  // ADD: Convert string from Firestore to FarmerSubStatus enum
  static FarmerSubStatus farmerStageFromString(String stage) {
    switch (stage) {
      case 'pending':
        return FarmerSubStatus.pending;
      case 'to_pack':
        return FarmerSubStatus.toPack;
      case 'to_handover':
        return FarmerSubStatus.toHandover;
      case 'shipping':
        return FarmerSubStatus.shipping;
      case 'completed':
        return FarmerSubStatus.completed;
      default:
        return FarmerSubStatus.pending;
    }
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toFirestore()).toList(),
      'farmer_id': farmerId,
      'farmer_stage': Order.farmerStageToString(farmerStage),
      'recipient_name': recipientName,
      'contact_number': contactNumber,
      'shipping_address': shippingAddress,
      'date_placed': Timestamp.fromDate(datePlaced),
      'date_delivered': dateDelivered != null ? Timestamp.fromDate(dateDelivered!) : null,
      'status': status.toString().split('.').last,
    };
  }

  // Create from Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse items
    final itemsData = (data['items'] as List<dynamic>?) ?? [];
    final items = <CartItem>[];

    for (var itemData in itemsData) {
      try {
        if (itemData is Map<String, dynamic>) {
          items.add(CartItem.fromFirestore(itemData));
        }
      } catch (e) {
        print('Error parsing cart item: $e');
      }
    }

    // Parse dates
    final datePlacedTimestamp = data['date_placed'] as Timestamp?;
    final datePlaced = datePlacedTimestamp?.toDate() ?? DateTime.now();

    final dateDeliveredTimestamp = data['date_delivered'] as Timestamp?;
    final dateDelivered = dateDeliveredTimestamp?.toDate();

    // Parse status
    final statusStr = data['status'] as String? ?? 'to_pay';
    final farmerStageStr = data['farmer_stage'] as String? ?? 'pending';

    return Order(
      id: doc.id,
      userId: data['user_id'] ?? '',
      items: items,
      farmerId: data['farmer_id'] ?? '',
      farmerStage: Order.farmerStageFromString(farmerStageStr),
      recipientName: data['recipient_name'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      shippingAddress: data['shipping_address'] ?? '',
      datePlaced: datePlaced,
      dateDelivered: dateDelivered,
      status: _statusFromString(statusStr),
    );
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'to_pay':
        return OrderStatus.toPay;
      case 'to_ship':
        return OrderStatus.toShip;
      case 'to_receive':
        return OrderStatus.toReceive;
      case 'to_rate':
        return OrderStatus.toRate;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.toPay;
    }
  }
}

class OrderWithFarmerStage {
  final Order order;
  final FarmerSubStatus farmerStage;

  OrderWithFarmerStage({
    required this.order,
    required this.farmerStage,
  });

  Order fromDocument(Map<String, dynamic> data) {
    return Order(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      farmerId: data['farmer_id'] ?? '',
      farmerStage: Order.farmerStageFromString(data['farmer_stage'] ?? 'pending'),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromDocument(item))
          .toList(),
      recipientName: data['recipient_name'] ?? '',
      contactNumber: data['contact_number'] ?? '',
      shippingAddress: data['shipping_address'] ?? '',
      datePlaced: (data['date_placed'] as Timestamp).toDate(),
      dateDelivered: data['date_delivered'] != null
          ? (data['date_delivered'] as Timestamp).toDate()
          : null,
      status: OrderStatus.values.firstWhere(
              (e) => e.toString() == 'OrderStatus.${data['status']}',
          orElse: () => OrderStatus.toPay),
    );
  }
}