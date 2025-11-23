// OrderManagementPage.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerOrderCard.dart';
import 'package:bukidlink/data/TestOrdersData.dart';
import 'package:bukidlink/models/FarmerOrderSubStatus.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
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

  // Simulated current farmer — in real app replace with logged-in farmer's farm name
  final String currentFarmerName = 'Farmjuseyo';

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

  List<FarmerOrder> _ordersForTab(String tabLabel, {DateTimeRange? dateRange}) {
    final stage = _farmerStageFromTabLabel(tabLabel);

    // Filter generated farmerOrders by farmerName and stage
    var filtered = TestOrders.generateFarmerOrders()
        .where((fo) => fo.farmerName == currentFarmerName && fo.farmerStage == stage)
        .toList();

    // Apply date filtering if provided
    if (dateRange != null) {
      filtered = filtered.where((fo) {
        final orderDate = fo.datePlaced;
        return orderDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // debug log
    print(">>> TAB: $tabLabel | FARMER: $currentFarmerName | FOUND: ${filtered.length}");
    return filtered;
  }

  // Bulk accept all pending orders
  void _acceptAllPending() {
    final orders = _ordersForTab('Pending');
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending orders to accept.')),
      );
      return;
    }

    for (var order in orders) {
      // Update status to toPack (simulate API call)
      order.farmerStage = FarmerSubStatus.toPack;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${orders.length} pending orders accepted!')),
    );
  }

  // Print receipts for toPack orders (with date filter)
  void _printReceipts() async {
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

    final orders = _ordersForTab('To Pack', dateRange: dateRange);
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders to print in selected date range.')),
      );
      return;
    }

    // Generate and show PDF preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generateReceiptsPdf(orders),
    );
  }

  // Handover to courier for toHandover orders (with date filter)
  void _handoverToCourier() async {
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

    final orders = _ordersForTab('To Handover', dateRange: dateRange);
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders to handover in selected date range.')),
      );
      return;
    }

    for (var order in orders) {
      // Update status to shipping (simulate API call)
      order.farmerStage = FarmerSubStatus.shipping;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${orders.length} orders handed over to courier!')),
    );
  }

  // PDF generation for receipts
  Future<Uint8List> _generateReceiptsPdf(List<FarmerOrder> orders) async {
    final pdf = pw.Document();

    for (var order in orders) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
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
                        currentFarmerName,
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Order Info
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Order ID: ${order.orderId}',
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

                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    // Header row
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
                    // Item rows
                    ...order.items.map((item) {
                      final total = item.product.price * item.quantity;
                      return pw.TableRow(
                        children: [
                          _buildTableCell(item.product.name),
                          _buildTableCell('${item.quantity}'),
                          _buildTableCell('₱${item.product.price.toStringAsFixed(2)}'),
                          _buildTableCell('₱${total.toStringAsFixed(2)}'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Total
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

                // Footer
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
          final orders = _ordersForTab(tabLabel);

          return Column(
            children: [
              // Bulk action buttons with improved styling
              if (tabLabel == 'Pending')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: _acceptAllPending,
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
              if (tabLabel == 'To Pack')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: _printReceipts,
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
              if (tabLabel == 'To Handover')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: _handoverToCourier,
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
              // Orders list
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
                    return FarmerOrderCard(orderWrapper: orders[index]);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 3),
    );
  }
}