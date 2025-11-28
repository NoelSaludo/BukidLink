import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/StoreProductCard.dart';
import 'package:bukidlink/widgets/farmer/SoldOutProductCard.dart';
import 'package:bukidlink/widgets/farmer/TradeOfferCard.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/TradeModels.dart';
import 'package:bukidlink/pages/farmer/SellPage.dart';
import 'package:bukidlink/pages/farmer/EditPage.dart';
import 'package:bukidlink/services/FarmService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:bukidlink/services/TradeService.dart';

// Helper class to hold the pair for display
class TradeOfferPair {
  final TradeListing listing;
  final TradeOfferRequest offer;
  TradeOfferPair({required this.listing, required this.offer});
}

class FarmerStorePage extends StatefulWidget {
  const FarmerStorePage({super.key});

  @override
  State<FarmerStorePage> createState() => _FarmerStorePageState();
}

class _FarmerStorePageState extends State<FarmerStorePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FarmService _farmService = FarmService();
  final TradeService _tradeService = TradeService();
  bool _isLoading = true;

  List<Product> _onSaleProducts = [];
  List<Product> _soldOutProducts = [];
  List<Product> _archivedProducts = [];
  List<TradeOfferPair> _tradeOffers = []; // Changed to use Firebase wrapper

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

    // 1. Fetch Store Products
    try {
      final user = UserService().getCurrentUser();
      final String? farmId = user?.farmId?.id;

      if (farmId != null) {
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
          _onSaleProducts = onSale;
          _soldOutProducts = soldOut;
          _archivedProducts = archived;
        }
      } else {
        print('User has no farm ID linked.');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }

    // 2. Fetch Trade Offers
    try {
      await _fetchTradeOffers();
    } catch (e) {
      print('Error fetching trades: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTradeOffers() async {
    // 1. Get all listings created by this farmer
    final listings = await _tradeService.fetchMyListingsFuture();
    final List<TradeOfferPair> allOffers = [];

    // 2. For each listing, get the offers
    for (var listing in listings) {
      final offers = await _tradeService.fetchOffersForListingFuture(
        listing.id,
      );

      for (var offer in offers) {
        // Only show pending offers for now
        if (offer.status == 'pending') {
          allOffers.add(TradeOfferPair(listing: listing, offer: offer));
        }
      }
    }

    if (mounted) {
      _tradeOffers = allOffers;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Calculate sold count based on stock difference (mock calculation)
  int _getSoldCount(Product product) {
    return 0;
  }

  // Calculate total earnings for a sold out product
  double _getTotalEarnings(Product product) {
    return 0.0;
  }

  // Get rating for sold out products
  double _getProductRating(Product product) {
    return product.rating ?? 0.0;
  }

  void _handleEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPage(product: product)),
    ).then((_) => _fetchProducts());
  }

  void _handleRemoveProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.CARD_BACKGROUND,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Product', style: AppTextStyles.DIALOG_TITLE),
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
              Navigator.pop(context);
              try {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Archiving product...')),
                  );
                }
                await _farmService.archiveProduct(product.id);
                if (mounted) {
                  _fetchProducts();
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
                      content: Text('Error archiving: $e'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Restoring product...')));
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
            content: Text('Error restoring: $e'),
            backgroundColor: AppColors.ERROR_RED,
          ),
        );
      }
    }
  }

  void _handleSellProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SellPage()),
    ).then((_) => _fetchProducts());
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    unselectedLabelStyle:
                        AppTextStyles.FARMER_TAB_LABEL_UNSELECTED,
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.storefront_outlined, size: 20),
                              const SizedBox(width: 8),
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
                              const Icon(
                                Icons.remove_shopping_cart_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
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
                              const Icon(Icons.inventory_2_outlined, size: 20),
                              const SizedBox(width: 8),
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
                              const Icon(Icons.swap_horiz_outlined, size: 20),
                              const SizedBox(width: 8),
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
                      _buildOnSaleList(),
                      _buildSoldOutList(),
                      _buildArchivedList(),
                      _buildTradesList(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 0),
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
        final pair = _tradeOffers[index];

        // Convert Listing/Offer to dummy Products for UI compatibility
        final myProduct = _createDummyProductFromListing(pair.listing);
        final offerProduct = _createDummyProductFromOffer(pair.offer);

        // Parse quantities
        final myQty = _parseQuantity(pair.listing.quantity);
        final offerQty = _parseQuantity(pair.offer.itemQuantity);

        return TradeOfferCard(
          myProduct: myProduct,
          offerProduct: offerProduct,
          myQuantity: myQty,
          offerQuantity: offerQty,
          onAccept: () => _handleAcceptTrade(pair),
          onDecline: () => _handleDeclineTrade(pair),
        );
      },
    );
  }

  // --- HELPERS to parse quantities and map models ---

  double _parseQuantity(String q) {
    final parts = q.trim().split(' ');
    if (parts.isNotEmpty) {
      return double.tryParse(parts.first) ?? 1.0;
    }
    return 1.0;
  }

  String _parseUnit(String q) {
    final parts = q.trim().split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ');
    }
    return 'Unit';
  }

  Product _createDummyProductFromListing(TradeListing listing) {
    return Product(
      id: listing.id,
      name: listing.name,
      farmName: "My Farm", // Or fetch current user farm name
      imagePath: listing.image.isNotEmpty
          ? listing.image
          : 'assets/images/default_cover_photo.png',
      category: 'Trade',
      price: 0,
      availability: 'In Stock',
      stockCount: 1,
      unit: _parseUnit(listing.quantity),
    );
  }

  Product _createDummyProductFromOffer(TradeOfferRequest offer) {
    return Product(
      id: offer.id,
      name: offer.itemName,
      farmName: offer.offeredByName, // Display name of the person offering
      imagePath: offer.imagePath.isNotEmpty
          ? offer.imagePath
          : 'assets/images/default_cover_photo.png',
      category: 'Trade Offer',
      price: 0,
      availability: 'Pending',
      stockCount: 1,
      unit: _parseUnit(offer.itemQuantity),
    );
  }

  void _handleAcceptTrade(TradeOfferPair pair) async {
    // TODO: Implement full accept logic (messaging, inventory)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accepting trade... (Logic to be implemented)'),
      ),
    );

    // For now, let's just update status in FB so it disappears from 'pending' list
    await _tradeService.acceptOffer(pair.offer.id);
    _fetchProducts(); // Refresh
  }

  void _handleDeclineTrade(TradeOfferPair pair) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Declining trade offer...')),
        );
      }

      await _tradeService.declineOffer(pair.offer.id, pair.listing.id);

      if (mounted) {
        _fetchProducts(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trade offer from ${pair.offer.offeredByName} declined',
            ),
            backgroundColor: AppColors.SUCCESS_GREEN,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining trade: $e'),
            backgroundColor: AppColors.ERROR_RED,
          ),
        );
      }
    }
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
