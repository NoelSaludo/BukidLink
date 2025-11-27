import 'package:bukidlink/models/CartItem.dart';
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
  final List<CartItem> items;
  final String recipientName;
  final String contactNumber;
  final String shippingAddress;
  final DateTime datePlaced;
  DateTime? dateDelivered;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.recipientName,
    required this.contactNumber,
    required this.shippingAddress,
    required this.datePlaced,
    this.dateDelivered,
    required this.status,
  });

  /// Compute total amount from all cart items
  double get total => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Check if all products in this order are rated
  bool get isAllRated {
    return items.every((item) => (item.product?.rating ?? 0) > 0);
  }

  Order fromDocument(Map<String, dynamic> data) {
    return Order(
      id: data['id'] ?? '',
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
