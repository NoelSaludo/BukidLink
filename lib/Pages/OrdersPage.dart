import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/pages/RatePage.dart';
import 'package:bukidlink/pages/OrderDetailsPage.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final OrderService _orderService = OrderService.shared;

  final List<OrderStatus> stages = [
    OrderStatus.toPay,
    OrderStatus.toShip,
    OrderStatus.toReceive,
    OrderStatus.toRate,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: stages.length, vsync: this);

    debugPrint(' OrdersPage initialized');

    // Initialize orders for current user
    _orderService.initializeForCurrentUser().then((_) {
      debugPrint(' Orders loaded in OrdersPage');
      debugPrint('   Total orders: ${_orderService.orders.length}');
      if (_orderService.orders.isNotEmpty) {
        for (var order in _orderService.orders) {
          debugPrint('   - Order ${order.id}:');
          debugPrint('     status: ${order.status}');
          debugPrint('     farmer_stage: ${order.farmerStage}');
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> updateOrderStage(String orderId) async {
    final currentOrder = _orderService.orders.firstWhere((o) => o.id == orderId);
    final currentStatus = currentOrder.status;

    OrderStatus nextStatus;
    FarmerSubStatus? nextFarmerStage;

    switch (currentStatus) {
      case OrderStatus.toPay:
        nextStatus = OrderStatus.toShip;
        break;
      case OrderStatus.toShip:
        nextStatus = OrderStatus.toReceive;
        break;
      case OrderStatus.toReceive:
        nextStatus = OrderStatus.toRate;
        nextFarmerStage = FarmerSubStatus.completed;
        currentOrder.dateDelivered = DateTime.now();
        break;
      case OrderStatus.toRate:
        nextStatus = OrderStatus.completed;
        break;
      case OrderStatus.completed:
        nextStatus = OrderStatus.completed;
        break;
    }

    await _orderService.updateOrderStatus(orderId, nextStatus);
    if (nextFarmerStage != null) {
      await OrderService.shared.updateFarmerStage(orderId, nextFarmerStage);
    }
    if (mounted) setState(() {});

    final nextIndex = stages.indexOf(nextStatus);
    if (nextIndex != -1 && nextIndex != _tabController.index) {
      _tabController.animateTo(nextIndex);
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
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

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.toPay:
        return Colors.orange;
      case OrderStatus.toShip:
        return Colors.blue;
      case OrderStatus.toReceive:
        return Colors.purple;
      case OrderStatus.toRate:
        return Colors.amber;
      case OrderStatus.completed:
        return Colors.green;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.toPay:
        return Icons.payment;
      case OrderStatus.toShip:
        return Icons.inventory_2;
      case OrderStatus.toReceive:
        return Icons.local_shipping;
      case OrderStatus.toRate:
        return Icons.star_rate;
      case OrderStatus.completed:
        return Icons.check_circle;
    }
  }

  Map<String, List<CartItem>> _groupItemsByFarm(List<CartItem> items) {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      if (item.product == null) continue;
      final farm = item.product!.farmName;
      grouped.putIfAbsent(farm, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final tabLabels = stages.map((s) => _statusLabel(s)).toList();

    debugPrint('🎨 Building OrdersPage. Total orders: ${_orderService.orders.length}');

    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        elevation: 0,
        title: Text('Orders', style: AppTextStyles.PRODUCT_INFO_TITLE),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: tabLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      // StreamBuilder for real-time updates
      body: StreamBuilder<List<Order>>(
        stream: _orderService.ordersStream(),
        builder: (context, snapshot) {
          debugPrint('🔄 StreamBuilder rebuild');
          debugPrint('   Connection state: ${snapshot.connectionState}');
          debugPrint('   Has data: ${snapshot.hasData}');
          debugPrint('   Orders count: ${snapshot.data?.length ?? 0}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final allOrders = snapshot.data ?? [];

          if (allOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: stages.map((stage) {
              final stageOrders = allOrders.where((o) => o.status == stage).toList();

              debugPrint('📊 Tab "${_statusLabel(stage)}": ${stageOrders.length} orders');

              if (stageOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _statusIcon(stage),
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No orders in "${_statusLabel(stage)}"',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stageOrders.length,
                itemBuilder: (context, index) {
                  final order = stageOrders[index];
                  return _buildOrderCard(order);
                },
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProductImage(String imagePath) {
    return ProductImage(
      imagePath: imagePath,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
    );
  }

  Widget _buildOrderCard(Order order) {
    return InkWell(
      onTap: order.status != OrderStatus.toRate
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsPage(order: order),
          ),
        );
      }
          : null,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.green.withOpacity(0.1),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header with ID and Status Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 18,
                          color: _statusColor(order.status),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(order.status),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(order.status),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(order.status),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Items
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._groupItemsByFarm(order.items).entries.map((entry) {
                    final farmName = entry.key;
                    final farmItems = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmName,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...farmItems.map((item) {
                          if (item.product == null) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildProductImage(item.product!.imagePath),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product!.name,
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₱${item.product!.price.toStringAsFixed(2)} each',
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Qty: ${item.amount}',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (order.status == OrderStatus.toRate)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      final starValue = index + 1;
                                      return IconButton(
                                        icon: Icon(
                                          starValue <= item.product!.tempRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () async {

                                          final result = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RatePage(
                                                product: item.product!,
                                                orderId: order.id,
                                                initialRating: starValue.toDouble(),
                                              ),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            setState(() {});
                                          }
                                        },
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(),
                      ],
                    );
                  }).toList(),

                  // Total Amount
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ₱${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  if (order.status == OrderStatus.toReceive) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => updateOrderStage(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Order Received',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}