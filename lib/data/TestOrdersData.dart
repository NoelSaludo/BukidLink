import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/data/ProductData.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';

class TestOrders {
  static final List<Order> orders = [
    Order(
      id: 'ORD001',
      items: [
        CartItem(id: 'CI001', product: ProductData.getProductById('1')!, quantity: 2),
        CartItem(id: 'CI002', product: ProductData.getProductById('2')!, quantity: 1),
      ],
      recipientName: 'Juan Dela Cruz',
      contactNumber: '09123456789',
      shippingAddress: 'Barangay 1, Batangas City',
      datePlaced: DateTime.now().subtract(const Duration(hours: 3)),
      status: OrderStatus.toPay,
    ),
    Order(
      id: 'ORD002',
      items: [
        CartItem(id: 'CI003', product: ProductData.getProductById('2')!, quantity: 3),
      ],
      recipientName: 'Maria Santos',
      contactNumber: '09123456780',
      shippingAddress: 'Barangay 2, Batangas City',
      datePlaced: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.toShip,
    ),
    Order(
      id: 'ORD003',
      items: [
        CartItem(id: 'CI004', product: ProductData.getProductById('3')!, quantity: 1),
        CartItem(id: 'CI005', product: ProductData.getProductById('4')!, quantity: 2),
      ],
      recipientName: 'Pedro Reyes',
      contactNumber: '09123456781',
      shippingAddress: 'Barangay 3, Batangas City',
      datePlaced: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.toShip,
    ),
    Order(
      id: 'ORD004',
      items: [
        CartItem(id: 'CI006', product: ProductData.getProductById('5')!, quantity: 1),
      ],
      recipientName: 'Ana Lopez',
      contactNumber: '09123456782',
      shippingAddress: 'Barangay 4, Batangas City',
      datePlaced: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.toReceive,
    ),
    Order(
      id: 'ORD005',
      items: [
        CartItem(id: 'CI007', product: ProductData.getProductById('1')!, quantity: 1),
        CartItem(id: 'CI008', product: ProductData.getProductById('4')!, quantity: 1),
      ],
      recipientName: 'Juan Dela Cruz',
      contactNumber: '09123456789',
      shippingAddress: 'Barangay 1, Batangas City',
      datePlaced: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.completed,
    ),
  ];

  /// Each FarmerOrder represents the part of the original Order that belongs to a single farm.
  static List<FarmerOrder> generateFarmerOrders() {
    final List<FarmerOrder> result = [];

    for (final order in orders) {
      // group items by farmName
      final Map<String, List<CartItem>> itemsByFarm = {};
      for (final item in order.items) {
        final farm = item.product.farmName;
        itemsByFarm.putIfAbsent(farm, () => []).add(item);
      }

      // create a FarmerOrder for each farm in this order
      itemsByFarm.forEach((farmName, items) {
        final farmerStage = _mapOrderStatusToFarmerStage(order.status);
        final fo = FarmerOrder(
          id: '${order.id}_$farmName',
          orderId: order.id,
          farmerName: farmName,
          items: items,
          recipientName: order.recipientName,
          contactNumber: order.contactNumber,
          shippingAddress: order.shippingAddress,
          datePlaced: order.datePlaced,
          dateDelivered: order.dateDelivered,
          farmerStage: farmerStage,
        );
        result.add(fo);
      });
    }

    return result;
  }

  static FarmerSubStatus _mapOrderStatusToFarmerStage(OrderStatus status) {
    switch (status) {
      case OrderStatus.toPay:
        return FarmerSubStatus.pending;
      case OrderStatus.toShip:
        return FarmerSubStatus.toPack;
      case OrderStatus.toReceive:
        return FarmerSubStatus.shipping;
      case OrderStatus.completed:
        return FarmerSubStatus.completed;
      default:
        return FarmerSubStatus.pending;
    }
  }

  /// A cached convenience list you can use in the UI:
  static final List<FarmerOrder> farmerOrders = generateFarmerOrders();

  /// Helper to get orders for a specific farm name
  static List<FarmerOrder> getOrdersForFarm(String farmName) {
    return farmerOrders.where((fo) => fo.farmerName == farmName).toList();
  }
}

/// Farmer-specific order model (test/dev)
class FarmerOrder {
  final String id; // unique id for this farmer-specific order (e.g. ORD001_De Castro Farms)
  final String orderId; // original customer order id
  final String farmerName; // used as farmerId
  final List<CartItem> items;
  final String recipientName;
  final String contactNumber;
  final String shippingAddress;
  final DateTime datePlaced;
  DateTime? dateDelivered;
  FarmerSubStatus farmerStage;

  FarmerOrder({
    required this.id,
    required this.orderId,
    required this.farmerName,
    required this.items,
    required this.recipientName,
    required this.contactNumber,
    required this.shippingAddress,
    required this.datePlaced,
    this.dateDelivered,
    required this.farmerStage,
  });

  double get total => items.fold(0.0, (sum, it) => sum + it.totalPrice);
}
