import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  static final OrderService shared = OrderService._internal();
  OrderService._internal();
  factory OrderService() => shared;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String? get _effectiveUserId => UserService.currentUser?.id ?? _auth.currentUser?.uid;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  CollectionReference get _ordersCollection => _firestore.collection('orders');

  Future<void> initializeForCurrentUser() async {
    final userId = UserService.currentUser?.id;

    if (userId == null) {
      debugPrint('No user logged in');
      _orders = [];
      return;
    }

    try {
      final snapshot = await _ordersCollection
          .where('user_id', isEqualTo: userId)
          .orderBy('date_placed', descending: true)
          .get();

      final ordersWithProducts = <Order>[];
      for (var doc in snapshot.docs) {
        final order = await _orderFromDocument(doc);
        if (order != null) {
          ordersWithProducts.add(order);
        }
      }

      _orders = ordersWithProducts;
    } catch (e, stackTrace) {
      debugPrint('Error loading orders: $e');
      debugPrint('Stack trace: $stackTrace');
      _orders = [];
    }
  }

  Stream<List<Order>> ordersStream() {
    final userId = UserService.currentUser?.id;

    if (userId == null) {
      return Stream.value([]);
    }

    return _ordersCollection
        .where('user_id', isEqualTo: userId)
        .orderBy('date_placed', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final ordersWithProducts = <Order>[];
      for (var doc in snapshot.docs) {
        final order = await _orderFromDocument(doc);
        if (order != null) {
          ordersWithProducts.add(order);
        }
      }

      _orders = ordersWithProducts;
      return _orders;
    });
  }

  Map<String, List<CartItem>> _groupItemsByFarmer(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};

    for (var item in items) {
      final farmerId = item.product?.farmId;
      if (farmerId != null && farmerId.isNotEmpty) {
        grouped.putIfAbsent(farmerId, () => []);
        grouped[farmerId]!.add(item);
      }
    }

    return grouped;
  }

  Future<List<String>> addOrdersFromCart({
    required List<CartItem> items,
    required String recipientName,
    required String contactNumber,
    required String shippingAddress,
  }) async {
    if (_effectiveUserId == null) {
      debugPrint('User not logged in');
      return [];
    }

    try {
      final itemsByFarmer = _groupItemsByFarmer(items);

      if (itemsByFarmer.isEmpty) {
        debugPrint('No valid items with farmer IDs');
        return [];
      }

      final List<String> createdOrderIds = [];

      for (var entry in itemsByFarmer.entries) {
        final farmerId = entry.key;
        final farmerItems = entry.value;

        final orderRef = _firestore.collection('orders').doc();
        final orderId = orderRef.id;

        final itemsData = farmerItems.map((item) => {
          'product_id': item.productId,
          'amount': item.amount,
        }).toList();

        final total = farmerItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

        await orderRef.set({
          'user_id': _effectiveUserId,
          'items': itemsData,
          'farmer_id': farmerId,
          'farmer_stage': 'pending',
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

        createdOrderIds.add(orderId);
      }

      return createdOrderIds;

    } catch (e, stackTrace) {
      debugPrint('Error adding orders: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  @Deprecated('Use addOrdersFromCart instead')
  Future<String?> addOrder({
    required List<CartItem> items,
    required String recipientName,
    required String contactNumber,
    required String shippingAddress,
    String? farmerId,
  }) async {
    final orders = await addOrdersFromCart(
      items: items,
      recipientName: recipientName,
      contactNumber: contactNumber,
      shippingAddress: shippingAddress,
    );

    return orders.isNotEmpty ? orders.first : null;
  }

  Future<bool> updateToShipping(String orderId) async {
    return await _updateOrderStatus(orderId, 'to_ship');
  }

  Future<bool> updateToReceive(String orderId) async {
    return await _updateOrderStatus(orderId, 'to_receive');
  }

  Future<bool> updateToRate(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'to_rate',
        'date_delivered': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order to rate: $e');
      return false;
    }
  }

  Future<bool> updateToComplete(String orderId) async {
    return await _updateOrderStatus(orderId, 'completed');
  }

  Future<bool> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

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

      return orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Order>> fetchMyOrders() async {
    if (_effectiveUserId == null) {
      debugPrint('User not logged in');
      return [];
    }
    return await fetchAllOrdersOfUser(_effectiveUserId!);
  }

  Future<Order?> _orderFromDocument(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;

      final itemsData = (data['items'] as List<dynamic>?) ?? [];
      final items = <CartItem>[];

      for (var itemData in itemsData) {
        final productId = itemData['product_id'] as String?;
        final amount = itemData['amount'] as int? ?? 0;

        if (productId != null) {
          final product = await ProductService.shared.getProductById(productId);

          final cartItem = CartItem(
            id: '${doc.id}_$productId',
            productId: productId,
            amount: amount,
            product: product,
          );

          items.add(cartItem);
        }
      }

      final statusStr = data['status'] as String? ?? 'to_pay';
      final status = _statusFromString(statusStr);

      final farmerStageStr = data['farmer_stage'] as String? ?? 'pending';
      final farmerStage = Order.farmerStageFromString(farmerStageStr);

      final datePlaced = (data['date_placed'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dateDelivered = (data['date_delivered'] as Timestamp?)?.toDate();

      final order = Order(
        id: doc.id,
        userId: data['user_id'] ?? '',
        farmerId: data['farmer_id'] ?? '',
        farmerStage: farmerStage,
        items: items,
        recipientName: data['recipient_name'] ?? '',
        contactNumber: data['contact_number'] ?? '',
        shippingAddress: data['shipping_address'] ?? '',
        datePlaced: datePlaced,
        dateDelivered: dateDelivered,
        status: status,
      );

      return order;
    } catch (e, stackTrace) {
      debugPrint('Error parsing order document ${doc.id}: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

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

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final statusString = _statusToString(newStatus);
      final updateData = <String, dynamic>{
        'status': statusString,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (newStatus == OrderStatus.toRate || newStatus == OrderStatus.completed) {
        updateData['date_delivered'] = FieldValue.serverTimestamp();
      }

      await _ordersCollection.doc(orderId).update(updateData);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index].status = newStatus;
        if (newStatus == OrderStatus.toRate || newStatus == OrderStatus.completed) {
          _orders[index].dateDelivered = DateTime.now();
        }
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
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

  Future<void> checkAndMarkCompleted(Order order) async {
    if (order.isAllRated && order.status == OrderStatus.toRate) {
      await updateOrderStatus(order.id, OrderStatus.completed);
    }
  }

  Future<void> removeOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
      _orders.removeWhere((o) => o.id == orderId);
    } catch (e) {
      debugPrint('Error removing order: $e');
    }
  }

  Stream<List<Order>> farmerOrdersStream(String farmerId, FarmerSubStatus stage) {
    final stageString = Order.farmerStageToString(stage);

    return _ordersCollection
        .where('farmer_id', isEqualTo: farmerId)
        .where('farmer_stage', isEqualTo: stageString)
        .orderBy('date_placed', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final ordersWithProducts = <Order>[];
      for (var doc in snapshot.docs) {
        final order = await _orderFromDocument(doc);
        if (order != null) {
          ordersWithProducts.add(order);
        }
      }

      return ordersWithProducts;
    });
  }

  Future<void> updateFarmerStage(String orderId, FarmerSubStatus newStage) async {
    try {
      final stageString = Order.farmerStageToString(newStage);
      final customerStatus = _mapFarmerStageToCustomerStatus(newStage);
      final customerStatusString = _statusToString(customerStatus);

      await _ordersCollection.doc(orderId).update({
        'farmer_stage': stageString,
        'status': customerStatusString,
        'updated_at': FieldValue.serverTimestamp(),
      });

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index].farmerStage = newStage;
        _orders[index].status = customerStatus;
      }
    } catch (e) {
      debugPrint('Error updating farmer stage: $e');
      rethrow;
    }
  }

  OrderStatus _mapFarmerStageToCustomerStatus(FarmerSubStatus farmerStage) {
    switch (farmerStage) {
      case FarmerSubStatus.pending:
        return OrderStatus.toPay;
      case FarmerSubStatus.toPack:
        return OrderStatus.toShip;
      case FarmerSubStatus.toHandover:
        return OrderStatus.toShip;
      case FarmerSubStatus.shipping:
        return OrderStatus.toReceive;
      case FarmerSubStatus.completed:
        return OrderStatus.toRate;
    }
  }
}