// OrderService.dart
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:uuid/uuid.dart';
import 'package:bukidlink/data/TestOrdersData.dart';

class OrderService {
  static final OrderService shared = OrderService._internal();
  OrderService._internal();
  factory OrderService() => shared;

  final List<Order> _orders = [];
  final _uuid = const Uuid();

  List<Order> get orders => _orders;

  void addOrder({
    required List<CartItem> items,
    required String recipientName,
    required String contactNumber,
    required String shippingAddress,
  }) {
    final newOrder = Order(
      id: _uuid.v4(),
      items: List.from(items),
      recipientName: recipientName,
      contactNumber: contactNumber,
      shippingAddress: shippingAddress,
      datePlaced: DateTime.now(),
      status: OrderStatus.toPay,
    );
    _orders.add(newOrder);
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) _orders[index].status = newStatus;
  }

  List<Order> getOrdersByStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();


  String labelFromStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return 'To Pay';
      case OrderStatus.toShip:
        return 'To Ship';
      case OrderStatus.toReceive:
        return 'To Receive';
      case OrderStatus.toRate:
        return 'Rate';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  OrderStatus statusFromLabel(String label) {
    switch (label) {
      case 'To Pay':
        return OrderStatus.toPay;
      case 'To Ship':
        return OrderStatus.toShip;
      case 'To Receive':
        return OrderStatus.toReceive;
      case 'Rate':
        return OrderStatus.toRate;
      case 'Completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.toPay;
    }
  }

  List<Order> getOrdersByStageLabel(String label) {
    final status = statusFromLabel(label);
    return getOrdersByStatus(status);
  }

  /// Mark as completed after rating all items
  void checkAndMarkCompleted(Order order) {
    if (order.isAllRated && order.status == OrderStatus.toRate) {
      updateOrderStatus(order.id, OrderStatus.completed);
    }
  }

  void removeOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
  }

  void loadTestOrders() {
    _orders.clear();
    _orders.addAll(TestOrders.orders);
  }

}
