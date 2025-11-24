import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/StoreProductCard.dart';
import 'package:bukidlink/widgets/farmer/SoldOutProductCard.dart';
import 'package:bukidlink/widgets/farmer/TradeOfferCard.dart';
import 'package:bukidlink/data/TradeOfferData.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/TradeOffer.dart';
import 'package:bukidlink/pages/farmer/SellPage.dart';
import 'package:bukidlink/pages/farmer/EditPage.dart';
import 'package:bukidlink/services/FarmService.dart';
import 'package:bukidlink/services/UserService.dart';

class FarmerStorePage extends StatefulWidget {
  const FarmerStorePage({super.key});

  @override
  State<FarmerStorePage> createState() => _FarmerStorePageState();
}

class _FarmerStorePageState extends State<FarmerStorePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FarmService _farmService = FarmService();
  bool _isLoading = true;

  List<Product> _onSaleProducts = [];
  List<Product> _soldOutProducts = [];
  List<Product> _archivedProducts = [];
  List<TradeOffer> get _tradeOffers => TradeOfferData.getPendingTradeOffers();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = UserService().getCurrentUser();
      // If user has a farmId (DocumentReference), we use its ID string.
      // If farmId is null, we can't fetch farm-specific products.
      final String? farmId = user?.farmId?.id;

      if (farmId != null) {
        // Fetch all products for the farm (FarmService filters nothing now, returns all)
        final products = await _farmService.fetchProductsByFarm(farmId);

        final onSale = <Product>[];
        final soldOut = <Product>[];
        final archived = <Product>[];

        for (var product in products) {
          if (!product.isVisible) {
            archived.add(product);
          } else if (product.stockCount > 0) {
            onSale.add(product);
          } else {
            soldOut.add(product);
          }
        }

        if (mounted) {
          setState(() {
            _onSaleProducts = onSale;
            _soldOutProducts = soldOut;
            _archivedProducts = archived;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        print('User has no farm ID linked.');
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Calculate sold count based on stock difference (mock calculation)
  int _getSoldCount(Product product) {
    // For now, returning 0 or placeholder logic as we don't have historical sales data linked here yet
    // In a real scenario, this might come from an Orders collection
    return 0;
  }

  // Calculate total earnings for a sold out product
  double _getTotalEarnings(Product product) {
    // Placeholder logic
    return 0.0;
  }

  // Get rating for sold out products
  double _getProductRating(Product product) {
    return product.rating ?? 0.0;
  }

  void _handleEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(product: product),
      ),
    ).then((_) => _fetchProducts()); // Refresh after edit
  }

  void _handleRemoveProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.CARD_BACKGROUND,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Remove Product',
          style: AppTextStyles.DIALOG_TITLE,
        ),
        content: Text(
          'Are you sure you want to remove "${product.name}"? This will archive the product.',
          style: AppTextStyles.BODY_TEXT,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.TEXT_SECONDARY),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                // Show loading indicator
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Archiving product...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }

                await _farmService.archiveProduct(product.id);

                if (mounted) {
                  _fetchProducts(); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} archived successfully'),
                      backgroundColor: AppColors.SUCCESS_GREEN,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error archiving product: $e'),
                      backgroundColor: AppColors.ERROR_RED,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.ERROR_RED),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRestoreProduct(Product product) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoring product...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      await _farmService.restoreProduct(product.id);

      if (mounted) {
        _fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} restored successfully'),
            backgroundColor: AppColors.SUCCESS_GREEN,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring product: $e'),
            backgroundColor: AppColors.ERROR_RED,
          ),
        );
      }
    }
  }

  void _handleSellProduct() {
    // Navigate to Sell Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SellPage(),
      ),
    ).then((_) => _fetchProducts()); // Refresh after adding new product
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
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('On sale'),
                              const SizedBox(width: 4),
                              Text('(${_onSaleProducts.length})'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sold Out'),
                              const SizedBox(width: 4),
                              Text('(${_soldOutProducts.length})'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Archived'),
                              const SizedBox(width: 4),
                              Text('(${_archivedProducts.length})'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Trades'),
                              const SizedBox(width: 4),
                              Text('(${_tradeOffers.length})'),
                            ],
                          ),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                // On Sale Tab
                _buildOnSaleList(),
                // Sold Out Tab
                _buildSoldOutList(),
                // Archived Tab
                _buildArchivedList(),
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

  Widget _buildArchivedList() {
    if (_archivedProducts.isEmpty) {
      return _buildEmptyState('No archived products');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _archivedProducts.length,
      itemBuilder: (context, index) {
        final product = _archivedProducts[index];
        final soldCount = _getSoldCount(product);

        return StoreProductCard(
          product: product,
          stockSold: soldCount,
          onEdit: () => _handleEditProduct(product),
          onRemove: () => _handleRestoreProduct(product),
          isArchived: true,
        );
      },
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
