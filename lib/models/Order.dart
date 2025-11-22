import 'package:bukidlink/models/CartItem.dart';

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
}
