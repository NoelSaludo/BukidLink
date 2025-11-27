import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/widgets/common/SearchBarWidget.dart';
import 'package:bukidlink/widgets/common/ProductCard.dart';
import 'package:bukidlink/widgets/category/CategoryAppBar.dart';
import 'package:bukidlink/widgets/category/SortBottomSheet.dart';
import 'package:bukidlink/data/ProductData.dart';
import 'package:bukidlink/models/Product.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _sortBy = 'Popular';
  String _searchQuery = '';
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _filteredProducts = ProductData.getProductsByCategory(
        widget.categoryName,
      );
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Product> products = ProductData.getProductsByCategory(
      widget.categoryName,
    );

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product.farmName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name: A-Z':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name: Z-A':
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Popular':
      default:
        // Keep original order (assumed to be by popularity)
        break;
    }

    setState(() {
      _filteredProducts = products;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        currentSort: _sortBy,
        onSortSelected: (sortOption) {
          setState(() {
            _sortBy = sortOption;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Column(
        children: [
          // Custom App Bar
          CategoryAppBar(
            categoryName: widget.categoryName,
            categoryIcon: widget.categoryIcon,
          ),

          Expanded(
            child: CustomScrollView(
              slivers: [
                // Search Bar Section
                SliverToBoxAdapter(
                  child: Container(
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
                    child: SearchBarWidget(onChanged: _onSearchChanged),
                  ),
                ),

                // Filter and Sort Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showSortOptions,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.sort, color: Colors.white, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Sort',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      '${_filteredProducts.length} Products Found',
                      style: AppTextStyles.farmName.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Products Grid
                _filteredProducts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: AppColors.TEXT_SECONDARY.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: AppTextStyles.productName.copyWith(
                                  color: AppColors.TEXT_SECONDARY,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: AppTextStyles.farmName,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return ProductCard(
                              product: _filteredProducts[index],
                              layout: ProductCardLayout.grid,
                              showAddButton: true,
                            );
                          }, childCount: _filteredProducts.length),
                        ),
                      ),

                // Bottom spacing
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
