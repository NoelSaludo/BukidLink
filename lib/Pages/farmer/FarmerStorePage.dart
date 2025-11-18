import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/StoreProductCard.dart';
import 'package:bukidlink/widgets/farmer/SoldOutProductCard.dart';
import 'package:bukidlink/widgets/farmer/TradeOfferCard.dart';
import 'package:bukidlink/data/ProductData.dart';
import 'package:bukidlink/data/TradeOfferData.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/TradeOffer.dart';

class FarmerStorePage extends StatefulWidget {
  const FarmerStorePage({super.key});

  @override
  State<FarmerStorePage> createState() => _FarmerStorePageState();
}

class _FarmerStorePageState extends State<FarmerStorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Product lists filtered by status
  List<Product> get _onSaleProducts => ProductData.getAllProducts()
      .where((p) => p.availability == 'In Stock')
      .toList();

  List<Product> get _soldOutProducts => ProductData.getAllProducts()
      .where((p) => p.availability == 'Out of Stock')
      .toList();

  List<TradeOffer> get _tradeOffers => TradeOfferData.getPendingTradeOffers();

  // ON SALE
  // Calculate sold count based on stock difference (mock calculation)
  int _getSoldCount(Product product) {
    // return a mock value based on product ID
    final mockSales = {
      '3': 30,  // Strawberry - sold out
      '7': 15,  // Carrots
      '8': 10,  // Eggplant
      '9': 50,  // Broccoli - sold out
      '10': 8,  // Potato
      '23': 15, // Rabbit Meat - sold out
    };
    return mockSales[product.id] ?? 0;
  }

  // SOLD OUT
  // Calculate total earnings for a sold out product
  double _getTotalEarnings(Product product) {
    final soldCount = _getSoldCount(product);
    return product.price * soldCount;
  }

  // Get rating for sold out products (mock data)
  double _getProductRating(Product product) {
    final mockRatings = {
      '3': 4.5,    // Strawberry
      '7': 4.0,    // Carrots
      '8': 5.0,    // Eggplant
      '9': 4.5,    // Broccoli
      '10': 4.5,   // Potato
      '23': 4.0,   // Rabbit Meat
    };
    return mockRatings[product.id] ?? product.rating ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEditProduct(Product product) {
    // TODO: Navigate to edit product page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${product.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleRemoveProduct(Product product) {
    // TODO: Show confirmation dialog and remove product
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Remove ${product.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleSellProduct() {
    // TODO: Navigate to add product page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new product'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Column(
        children: [
          const FarmerAppBar(),
          // Tabs Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.HEADER_GRADIENT_START,
                  AppColors.HEADER_GRADIENT_END,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.DARK_TEXT,
                    unselectedLabelColor: Colors.white,
                    labelStyle: AppTextStyles.FARMER_TAB_LABEL,
                    unselectedLabelStyle: AppTextStyles.FARMER_TAB_LABEL_UNSELECTED,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('On sale'),
                            const SizedBox(width: 4),
                            Text('(${_onSaleProducts.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sold Out'),
                            const SizedBox(width: 4),
                            Text('(${_soldOutProducts.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Trades'),
                            const SizedBox(width: 4),
                            Text('(${_tradeOffers.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Sell a product button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _handleSellProduct();
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.ACCENT_LIME,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sell a product',
                          style: AppTextStyles.SELL_PRODUCT_BUTTON,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // On Sale Tab
                _buildOnSaleList(),
                // Sold Out Tab
                _buildSoldOutList(),
                // Trades Tab
                _buildTradesList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildOnSaleList() {
    if (_onSaleProducts.isEmpty) {
      return _buildEmptyState('No products on sale');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _onSaleProducts.length,
      itemBuilder: (context, index) {
        final product = _onSaleProducts[index];
        final soldCount = _getSoldCount(product);

        return StoreProductCard(
          product: product,
          stockSold: soldCount,
          onEdit: () => _handleEditProduct(product),
          onRemove: () => _handleRemoveProduct(product),
        );
      },
    );
  }

  Widget _buildSoldOutList() {
    if (_soldOutProducts.isEmpty) {
      return _buildEmptyState('No sold out products');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _soldOutProducts.length,
      itemBuilder: (context, index) {
        final product = _soldOutProducts[index];
        final soldCount = _getSoldCount(product);
        final rating = _getProductRating(product);
        final totalEarnings = _getTotalEarnings(product);

        return SoldOutProductCard(
          product: product,
          soldCount: soldCount,
          rating: rating,
          totalEarnings: totalEarnings,
        );
      },
    );
  }

  Widget _buildTradesList() {
    if (_tradeOffers.isEmpty) {
      return _buildEmptyState('No trades yet');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tradeOffers.length,
      itemBuilder: (context, index) {
        final offer = _tradeOffers[index];

        return TradeOfferCard(
          myProduct: offer.myProduct,
          offerProduct: offer.offerProduct,
          myQuantity: offer.myQuantity,
          offerQuantity: offer.offerQuantity,
          onAccept: () => _handleAcceptTrade(offer),
          onDecline: () => _handleDeclineTrade(offer),
        );
      },
    );
  }

  void _handleAcceptTrade(TradeOffer offer) {
    // TODO: Implement accept trade logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted trade: ${offer.myProduct.name} for ${offer.offerProduct.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDeclineTrade(TradeOffer offer) {
    // TODO: Implement decline trade logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Declined trade: ${offer.myProduct.name} for ${offer.offerProduct.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.TEXT_SECONDARY.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.FARMER_EMPTY_STATE.copyWith(
              color: AppColors.TEXT_SECONDARY.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
