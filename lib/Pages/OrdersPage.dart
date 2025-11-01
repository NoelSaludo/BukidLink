import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/CartItem.dart';
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

  final Map<String, double> _quickRatings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: stages.length, vsync: this);
  }

  void updateOrderStage(String orderId) {
    final currentOrder = _orderService.orders.firstWhere((o) => o.id == orderId);
    final currentStatus = currentOrder.status;

    OrderStatus nextStatus;
    switch (currentStatus) {
      case OrderStatus.toPay:
        nextStatus = OrderStatus.toShip;
        break;
      case OrderStatus.toShip:
        nextStatus = OrderStatus.toReceive;
        break;
      case OrderStatus.toReceive:
        nextStatus = OrderStatus.toRate;
        currentOrder.dateDelivered = DateTime.now();
        break;
      case OrderStatus.toRate:
      case OrderStatus.completed:
        nextStatus = currentStatus;
        break;
    }

    _orderService.updateOrderStatus(orderId, nextStatus);
    setState(() {});

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

  @override
  Widget build(BuildContext context) {
    final tabLabels = stages.map((s) => _statusLabel(s)).toList();

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

      body: TabBarView(
        controller: _tabController,
        children: stages.map((stage) {
          final stageOrders = _orderService.getOrdersByStatus(stage);

          if (stageOrders.isEmpty) {
            return Center(child: Text('No orders in "${_statusLabel(stage)}"'));
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
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildOrderCard(Order order) {
    Map<String, List<CartItem>> _groupItemsByFarm(List<CartItem> items) {
      final Map<String, List<CartItem>> grouped = {};
      for (var item in items) {
        final farm = item.product.farmName;
        grouped.putIfAbsent(farm, () => []).add(item);
      }
      return grouped;
    }

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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item.product.imagePath,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₱${item.product.price.toStringAsFixed(
                                            2)} each',
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
                                      'Qty: ${item.quantity}',
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
                                      starValue <= item.product.tempRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        item.product.tempRating =
                                            starValue.toDouble();
                                      });

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              RatePage(
                                                product: item.product,
                                                initialRating: starValue
                                                    .toDouble(),
                                              ),
                                        ),
                                      ).then((_) {
                                        if (order.isAllRated) {
                                          _orderService.updateOrderStatus(
                                              order.id, OrderStatus.completed);
                                          setState(() {});
                                        }
                                      });
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
              const SizedBox(height: 8),
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              if (order.status != OrderStatus.toRate &&
                  order.status != OrderStatus.completed)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => updateOrderStage(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      order.status == OrderStatus.toPay
                          ? 'Approve & Ship'
                          : order.status == OrderStatus.toShip
                          ? 'Mark Shipped'
                          : 'Order Received',
                      style: const TextStyle(fontFamily: 'Outfit'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
