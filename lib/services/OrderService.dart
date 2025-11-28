import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:bukidlink/services/UserService.dart'; // Added to access app-level current user

class OrderService {
  static final OrderService shared = OrderService._internal();
  OrderService._internal();
  factory OrderService() => shared;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _effectiveUserId => UserService.currentUser?.id ?? _auth.currentUser?.uid;

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  // Add order to Firestore
  Future<String?> addOrder({
    required List<CartItem> items,
    required String recipientName,
    required String contactNumber,
    required String shippingAddress,
  }) async {
    if (_effectiveUserId == null) {
      debugPrint('User not logged in');
      return null;
    }

    try {
      final orderRef = _firestore.collection('orders').doc();
      final orderId = orderRef.id;

      // Convert items to Firestore format
      final itemsData = items.map((item) => {
        'product_id': item.productId,
        'amount': item.amount,
      }).toList();

      // Calculate total
      final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

      await orderRef.set({
        'user_id': _effectiveUserId,
        'items': itemsData,
        'recipient_name': recipientName,
        'contact_number': contactNumber,
        'shipping_address': shippingAddress,
        'date_placed': FieldValue.serverTimestamp(),
        'date_delivered': null,
        'status': 'to_pay',
        'total': total,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Order created successfully: $orderId');
      return orderId;
    } catch (e) {
      debugPrint('Error adding order: $e');
      return null;
    }
  }

  // Update order to shipping status
  Future<bool> updateToShipping(String orderId) async {
    return await _updateOrderStatus(orderId, 'to_ship');
  }

  // Update order to receive status
  Future<bool> updateToReceive(String orderId) async {
    return await _updateOrderStatus(orderId, 'to_receive');
  }

  // Update order to rate status
  Future<bool> updateToRate(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'to_rate',
        'date_delivered': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Order $orderId updated to rate status');
      return true;
    } catch (e) {
      debugPrint('Error updating order to rate: $e');
      return false;
    }
  }

  // Update order to complete status
  Future<bool> updateToComplete(String orderId) async {
    return await _updateOrderStatus(orderId, 'completed');
  }

  // Generic method to update order status
  Future<bool> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Order $orderId updated to $status');
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Fetch all orders of a specific user
  Future<List<Order>> fetchAllOrdersOfUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('date_placed', descending: true)
          .get();

      final orders = <Order>[];

      for (var doc in querySnapshot.docs) {
        final order = await _orderFromDocument(doc);
        if (order != null) {
          orders.add(order);
        }
      }

      _orders.clear();
      _orders.addAll(orders);

      debugPrint('Fetched ${orders.length} orders for user $userId');
      return orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  // Fetch all orders of current user
  Future<List<Order>> fetchMyOrders() async {
    if (_effectiveUserId == null) {
      debugPrint('User not logged in');
      return [];
    }
    return await fetchAllOrdersOfUser(_effectiveUserId!);
  }

  // Convert Firestore document to Order object
  Future<Order?> _orderFromDocument(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Parse items - need to fetch product details
      final itemsData = (data['items'] as List<dynamic>?) ?? [];
      final items = <CartItem>[];

      for (var itemData in itemsData) {
        final productId = itemData['product_id'] as String?;
        final amount = itemData['amount'] as int? ?? 0;

        if (productId != null) {
          // Create CartItem with productId - product will be fetched separately if needed
          items.add(CartItem(
            productId: productId,
            amount: amount,
            product: null, // Product should be fetched from ProductService if needed
          ));
        }
      }

      // Parse status
      final statusStr = data['status'] as String? ?? 'to_pay';
      final status = _statusFromString(statusStr);

      // Parse dates
      final datePlaced = (data['date_placed'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dateDelivered = (data['date_delivered'] as Timestamp?)?.toDate();

      return Order(
        id: doc.id,
        items: items,
        recipientName: data['recipient_name'] ?? '',
        contactNumber: data['contact_number'] ?? '',
        shippingAddress: data['shipping_address'] ?? '',
        datePlaced: datePlaced,
        dateDelivered: dateDelivered,
        status: status,
      );
    } catch (e) {
      debugPrint('Error parsing order document: $e');
      return null;
    }
  }

  // Convert string to OrderStatus enum
  OrderStatus _statusFromString(String status) {
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

  // Convert OrderStatus enum to string
  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return 'to_pay';
      case OrderStatus.toShip:
        return 'to_ship';
      case OrderStatus.toReceive:
        return 'to_receive';
      case OrderStatus.toRate:
        return 'to_rate';
      case OrderStatus.completed:
        return 'completed';
    }
  }

  // Legacy methods (kept for backward compatibility)
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = newStatus;
      // Also update in Firestore
      _updateOrderStatus(orderId, _statusToString(newStatus));
    }
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
}
