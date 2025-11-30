// import 'package:bukidlink/models/Order.dart';
// import 'package:bukidlink/models/CartItem.dart';
// import 'package:bukidlink/data/ProductData.dart';
// import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
//
// class TestOrders {
//   static final List<Order> orders = [
//     Order(
//       id: 'ORD001',
//       userId: 'test_user_1',
//       items: [
//         CartItem(id: 'CI001', product: ProductData.getProductById('1')!, quantity: 2),
//         CartItem(id: 'CI002', product: ProductData.getProductById('2')!, quantity: 1),
//       ],
//       farmerId: ProductData.getProductById('1')!.farmName,
//       farmerStage: FarmerSubStatus.pending,
//       recipientName: 'Juan Dela Cruz',
//       contactNumber: '09123456789',
//       shippingAddress: 'Barangay 1, Batangas City',
//       datePlaced: DateTime.now().subtract(const Duration(hours: 3)),
//       status: OrderStatus.toPay,
//     ),
//     Order(
//       id: 'ORD002',
//       userId: 'test_user_1',
//       items: [
//         CartItem(id: 'CI003', product: ProductData.getProductById('2')!, quantity: 3),
//       ],
//       farmerId: ProductData.getProductById('2')!.farmName,
//       farmerStage: FarmerSubStatus.toPack,
//       recipientName: 'Maria Santos',
//       contactNumber: '09123456780',
//       shippingAddress: 'Barangay 2, Batangas City',
//       datePlaced: DateTime.now().subtract(const Duration(days: 1)),
//       status: OrderStatus.toShip,
//     ),
//     Order(
//       id: 'ORD003',
//       userId: 'test_user_1',
//       items: [
//         CartItem(id: 'CI004', product: ProductData.getProductById('3')!, quantity: 1),
//         CartItem(id: 'CI005', product: ProductData.getProductById('4')!, quantity: 2),
//       ],
//       farmerId: ProductData.getProductById('3')!.farmName,
//       farmerStage: FarmerSubStatus.toPack,
//       recipientName: 'Pedro Reyes',
//       contactNumber: '09123456781',
//       shippingAddress: 'Barangay 3, Batangas City',
//       datePlaced: DateTime.now().subtract(const Duration(days: 2)),
//       status: OrderStatus.toShip,
//     ),
//     Order(
//       id: 'ORD004',
//       userId: 'test_user_1',
//       items: [
//         CartItem(id: 'CI006', product: ProductData.getProductById('5')!, quantity: 1),
//       ],
//       farmerId: ProductData.getProductById('5')!.farmName,
//       farmerStage: FarmerSubStatus.shipping,
//       recipientName: 'Ana Lopez',
//       contactNumber: '09123456782',
//       shippingAddress: 'Barangay 4, Batangas City',
//       datePlaced: DateTime.now().subtract(const Duration(days: 3)),
//       status: OrderStatus.toReceive,
//     ),
//     Order(
//       id: 'ORD005',
//       userId: 'test_user_1',
//       items: [
//         CartItem(id: 'CI007', product: ProductData.getProductById('1')!, quantity: 1),
//         CartItem(id: 'CI008', product: ProductData.getProductById('4')!, quantity: 1),
//       ],
//       farmerId: ProductData.getProductById('1')!.farmName,
//       farmerStage: FarmerSubStatus.completed,
//       recipientName: 'Juan Dela Cruz',
//       contactNumber: '09123456789',
//       shippingAddress: 'Barangay 1, Batangas City',
//       datePlaced: DateTime.now().subtract(const Duration(days: 5)),
//       status: OrderStatus.completed,
//     ),
//   ];
// }
