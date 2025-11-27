import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/store/StoreAppBar.dart';
import 'package:bukidlink/widgets/store/StoreHeaderCard.dart';
import 'package:bukidlink/widgets/store/StoreTabBar.dart';
import 'package:bukidlink/widgets/store/StoreProductGrid.dart';

class StorePage extends StatefulWidget {
  final String farmName;

  const StorePage({super.key, required this.farmName});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Product> _allStoreProducts = [];
  List<String> _categories = [];
  Map<String, int> _productCountByCategory = {};
  double? _averageRating;
  final ProductService _productService = ProductService();
  StreamSubscription<List<Product>>? _productsSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  void _loadStoreData() {
    // Subscribe to a real-time stream from ProductService and prepare UI state
    _isLoading = true;
    _productsSubscription = _productService.streamProducts().listen(
      (allProducts) {
        final storeProducts = allProducts
            .where((product) => product.farmName == widget.farmName)
            .toList();

        // Extract unique categories
        final categorySet = <String>{};
        for (var product in storeProducts) {
          categorySet.add(product.category);
        }
        final categories = ['All', ...categorySet.toList()..sort()];

        // Count products by category
        final productCountByCategory = <String, int>{};
        productCountByCategory['All'] = storeProducts.length;
        for (var category in categorySet) {
          productCountByCategory[category] = storeProducts
              .where((product) => product.category == category)
              .length;
        }

        // compute average rating from the storeProducts (only visible + with rating)
        double? computedAvg;
        final ratings = storeProducts
            .where((p) => p.rating != null)
            .map((p) => p.rating!)
            .toList();
        if (ratings.isNotEmpty) {
          computedAvg = ratings.reduce((a, b) => a + b) / ratings.length;
        } else {
          computedAvg = null;
        }

        setState(() {
          _allStoreProducts = storeProducts;
          _categories = categories;
          _productCountByCategory = productCountByCategory;
          _averageRating = computedAvg;

          // Recreate the TabController when number of categories changes,
          // but try to preserve the selected index.
          final previousIndex = _tabController?.index ?? 0;
          _tabController?.dispose();
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );
          // Clamp the index to the new range
          if (_tabController!.length > 0) {
            _tabController!.index = previousIndex.clamp(
              0,
              _tabController!.length - 1,
            );
          }

          _isLoading = false;
        });
      },
      onError: (e) {
        debugPrint('Error loading store products stream: $e');
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts() {
    final selectedCategory = _categories[_tabController?.index ?? 0];
    if (selectedCategory == 'All') {
      return _allStoreProducts;
    }
    return _allStoreProducts
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: StoreAppBar(farmName: widget.farmName),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_allStoreProducts.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      StoreHeaderCard(
                        farmName: widget.farmName,
                        totalProducts: _allStoreProducts.length,
                        categories: _productCountByCategory.keys.length - 1,
                        averageRating: _averageRating,
                      ),
                      StoreTabBar(
                        tabController: _tabController!,
                        categories: _categories,
                        productCounts: _productCountByCategory,
                        onTabChanged: () => setState(() {}),
                      ),
                      Expanded(
                        child: StoreProductGrid(
                          products: _getFilteredProducts(),
                          farmName: widget.farmName,
                        ),
                      ),
                    ],
                  )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80,
            color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products available',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.TEXT_SECONDARY,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This store doesn\'t have any products yet',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.TEXT_SECONDARY,
            ),
          ),
        ],
      ),
    );
  }
}
