import 'package:bukidlink/models/ProductReview.dart';
import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/pages/CartPage.dart';
import 'package:bukidlink/pages/AllReviewsPage.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:bukidlink/services/GeminiAIService.dart';
import 'package:bukidlink/widgets/productinfo/SuggestedProductsSection.dart';
import 'package:bukidlink/widgets/productinfo/ProductInfoAppBar.dart';
import 'package:bukidlink/widgets/productinfo/ProductHeaderWithQuantity.dart';
import 'package:bukidlink/widgets/productinfo/ProductDetailsCard.dart';
import 'package:bukidlink/widgets/productinfo/ProductReviewsSection.dart';
import 'package:bukidlink/widgets/productinfo/RecommendedProductsSection.dart';
import 'package:bukidlink/widgets/productinfo/BottomActionBar.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/services/UserService.dart';

class ProductInfoPage extends StatefulWidget {
  final Product product;
  final int currentNavIndex;

  const ProductInfoPage({
    super.key,
    required this.product,
    this.currentNavIndex = 0,
  });

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  static const int _minQuantity = 1;
  static const int _recommendedProductsLimit = 6;

  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();
  int _quantity = _minQuantity;
  late double _totalPrice;
  late Future<List<ProductReview>> _reviewsFuture = Future.value([]);
  List<Product> _recommendedProducts = [];
  List<Product> _aiSuggestedProducts = [];
  bool _isRecommendedLoading = true;
  bool _isAISuggestionsLoading = true;
  String? _resolvedFarmId;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
    // Fetch reviews for the current product from Firestore
    _reviewsFuture = _productService.fetchProductReviews(widget.product.id);
    if (widget.product.reviews != null) {
      _reviewsFuture = Future.value(widget.product.reviews);
    } else {
      debugPrint('No reviews found');
    }
    _loadRecommendedAndResolveFarm();
  }

  Future<void> _loadRecommendedAndResolveFarm() async {
    try {
      final all = await _productService.fetchProducts();
      _recommendedProducts = all
          .where(
            (p) =>
                p.category == widget.product.category &&
                p.id != widget.product.id,
          )
          .take(_recommendedProductsLimit)
          .toList();

      // Resolve farm id: prefer product.farmId, otherwise try to find user by username
      if (widget.product.farmId != null && widget.product.farmId!.isNotEmpty) {
        _resolvedFarmId = widget.product.farmId;
      } else {
        try {
          final uid = await _userService.getUserIdByUsername(
            widget.product.farmName,
          );
          _resolvedFarmId = uid;
        } catch (e) {
          debugPrint('Error resolving farm id: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading recommended products: $e');
    } finally {
      setState(() => _isRecommendedLoading = false);
      // kick off AI suggestions but don't block the UI
      debugPrint('Loading AI suggestions for product ${widget.product.id}');
      _loadAISuggestions(allProducts: await _productService.fetchProducts());
    }
  }

  Future<void> _loadAISuggestions({required List<Product> allProducts}) async {
    setState(() {
      _isAISuggestionsLoading = true;
    });

    try {
      // fetch all orders across users to compute co-purchase frequencies
      final orders = await OrderService.shared.fetchAllOrders();

      // Transform orders into lists of product ids
      final ordersProductIds = orders
          .map(
            (o) => o.items
                .map((it) => it.productId)
                .where((id) => id.isNotEmpty)
                .toList(),
          )
          .where((list) => list.isNotEmpty)
          .toList();

      final catalogIds = allProducts.map((p) => p.id).toList();

      final suggestedIds = await GeminiAIService.shared
          .suggestProductIdsFromOrders(
            orders: ordersProductIds,
            catalogIds: catalogIds,
            currentProductId: widget.product.id,
            limit: _recommendedProductsLimit,
          );

      if (suggestedIds.isNotEmpty) {
        final suggestedProducts = await _productService.fetchProductsByIds(
          suggestedIds,
        );
        debugPrint(
          'AI suggested products for ${widget.product.id}: ${suggestedProducts.map((p) => p.id).toList()}',
        );
        setState(() => _aiSuggestedProducts = suggestedProducts);
      }
    } catch (e) {
      debugPrint('Error loading AI suggestions: $e');
    } finally {
      setState(() => _isAISuggestionsLoading = false);
    }
  }

  // Helper that returns a network image when path is a URL, otherwise an asset image.
  Widget _buildImage(
    String path, {
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    final lower = path.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        },
      );
    }

    // Fallback to asset
    return Image.asset(
      path.isNotEmpty ? path : 'assets/images/default_cover_photo.png',
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      },
    );
  }

  void _handleQuantityChanged(int quantity) {
    setState(() {
      _quantity = quantity;
      _totalPrice = widget.product.price * quantity;
    });
  }

  void _handleAddToBasket() {
    _cartService.addItem(widget.product, _quantity);

    SnackBarHelper.showSuccess(
      context,
      'Added $_quantity x ${widget.product.name} to basket',
    );

    debugPrint(
      'Added to basket: ${widget.product.name} x $_quantity = PHP $_totalPrice',
    );
  }

  void _handleCartPressed() {
    PageNavigator().goToAndKeepWithTransition(
      context,
      const CartPage(),
      PageTransitionType.slideFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendedProducts = _recommendedProducts;

    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: ProductInfoAppBar(
        onBackPressed: () => PageNavigator().goBack(context),
        onCartPressed: _handleCartPressed,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline image card using network-capable helper so URLs load properly
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: _buildImage(
                        widget.product.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ProductHeaderWithQuantity(
              product: widget.product,
              quantity: _quantity,
              onQuantityChanged: _handleQuantityChanged,
            ),
            ProductDetailsCard(
              description:
                  widget.product.description ??
                  'Fresh and high-quality ${widget.product.name.toLowerCase()} sourced directly from local farms.',
              farmName: widget.product.farmName,
              farmId: _resolvedFarmId,
            ),
            // AI suggested products shown above the reviews
            _isAISuggestionsLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SuggestedProductsSection(
                    products: _aiSuggestedProducts,
                    excludeProductId: widget.product.id,
                  ),
            FutureBuilder<List<ProductReview>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final reviews = snapshot.data ?? [];
                return ProductReviewsSection(
                  reviews: reviews,
                  onViewAll: () => PageNavigator().goToAndKeepWithTransition(
                    context,
                    AllReviewsPage(reviews: reviews, product: widget.product),
                    PageTransitionType.slideFromRight,
                  ),
                );
              },
            ),
            _isRecommendedLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : RecommendedProductsSection(products: recommendedProducts),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        totalPrice: _totalPrice,
        quantity: _quantity,
        onAddToBasket: _handleAddToBasket,
      ),
    );
  }

  // farm id resolution and recommended products are handled in initState via
  // `_loadRecommendedAndResolveFarm` which sets `_resolvedFarmId`.
}
