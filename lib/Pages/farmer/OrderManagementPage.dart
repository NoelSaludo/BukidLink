// (Farmer View) OrderManagementPage.dart
import 'dart:typed_data';
import 'package:bukidlink/data/UserData.dart';
import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerOrderCard.dart';
import 'package:bukidlink/models/Order.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _FarmerOrderManagementPageState();
}

class _FarmerOrderManagementPageState extends State<OrderManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = [
    'Pending',
    'To Pack',
    'To Handover',
    'Shipping',
    'Completed'
  ];

  String get currentFarmId {
    final user = UserService.currentUser;
    final farmIdPath = user?.farmId?.path;
    final farmId = farmIdPath?.split('/').last ?? '';
    return farmId;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  FarmerSubStatus _farmerStageFromTabLabel(String label) {
    switch (label) {
      case 'Pending':
        return FarmerSubStatus.pending;
      case 'To Pack':
        return FarmerSubStatus.toPack;
      case 'To Handover':
        return FarmerSubStatus.toHandover;
      case 'Shipping':
        return FarmerSubStatus.shipping;
      case 'Completed':
        return FarmerSubStatus.completed;
      default:
        return FarmerSubStatus.pending;
    }
  }

  Future<void> _acceptAllPending(List<Order> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending orders to accept.')),
      );
      return;
    }

    try {
      for (var order in orders) {
        await OrderService.shared.updateFarmerStage(order.id, FarmerSubStatus.toPack);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${orders.length} pending orders accepted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting orders: $e')),
        );
      }
    }
  }

  Future<void> _printReceipts(List<Order> allToPackOrders) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateRange == null) return;

    final orders = allToPackOrders.where((order) {
      final orderDate = order.datePlaced;
      return orderDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
          orderDate.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders to print in selected date range.')),
      );
      return;
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generateReceiptsPdf(orders),
    );
  }

  Future<void> _handoverToCourier(List<Order> allToHandoverOrders) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (dateRange == null) return;

    final orders = allToHandoverOrders.where((order) {
      final orderDate = order.datePlaced;
      return orderDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
          orderDate.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders to handover in selected date range.')),
      );
      return;
    }

    try {
      for (var order in orders) {
        await OrderService.shared.updateFarmerStage(order.id, FarmerSubStatus.shipping);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${orders.length} orders handed over to courier!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error handing over orders: $e')),
        );
      }
    }
  }

  Future<Uint8List> _generateReceiptsPdf(List<Order> orders) async {
    final pdf = pw.Document();

    for (var order in orders) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PACKING RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        UserService.currentUser?.firstName ?? 'Farm',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Order ID: ${order.id}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Date: ${_formatDate(order.datePlaced)}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Customer: ${order.recipientName}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Contact: ${order.contactNumber}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Address: ${order.shippingAddress}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        _buildTableCell('Product', isHeader: true),
                        _buildTableCell('Qty', isHeader: true),
                        _buildTableCell('Price', isHeader: true),
                        _buildTableCell('Total', isHeader: true),
                      ],
                    ),
                    ...order.items.where((item) => item.product != null).map((item) {
                      final productPrice = item.product?.price ?? 0.0;
                      final productName = item.product?.name ?? 'Unknown Product';
                      final itemAmount = item.amount;
                      final total = productPrice * itemAmount;

                      return pw.TableRow(
                        children: [
                          _buildTableCell(productName),
                          _buildTableCell('$itemAmount'),
                          _buildTableCell('₱${productPrice.toStringAsFixed(2)}'),
                          _buildTableCell('₱${total.toStringAsFixed(2)}'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Text(
                      'TOTAL: ₱${order.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }

    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (currentFarmId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundYellow,
        appBar: AppBar(
          title: Text('Orders', style: AppTextStyles.PRODUCT_INFO_TITLE),
          backgroundColor: AppColors.HEADER_GRADIENT_START,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Farm ID Not Found',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your user account is not properly linked to a farm. Please contact support.',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 3),
      );
    }

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
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tabLabel) {
          final stage = _farmerStageFromTabLabel(tabLabel);

          return StreamBuilder<List<Order>>(
            stream: OrderService.shared.farmerOrdersStream(currentFarmId, stage),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading orders',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final orders = snapshot.data ?? [];

              return Column(
                children: [
                  if (tabLabel == 'Pending' && orders.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptAllPending(orders),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text(
                          'Accept All Orders',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  if (tabLabel == 'To Pack' && orders.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _printReceipts(orders),
                        icon: const Icon(Icons.print, color: Colors.white),
                        label: const Text(
                          'Print Receipts',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  if (tabLabel == 'To Handover' && orders.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _handoverToCourier(orders),
                        icon: const Icon(Icons.local_shipping, color: Colors.white),
                        label: const Text(
                          'Handover to Courier',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  Expanded(
                    child: orders.isEmpty
                        ? Center(
                      child: Text(
                        'No orders in "$tabLabel"',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return FarmerOrderCard(order: orders[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 3),
    );
  }
}