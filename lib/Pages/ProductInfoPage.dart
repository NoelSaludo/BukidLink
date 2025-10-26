import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/data/ProductData.dart';
import 'package:bukidlink/data/ReviewData.dart';
import 'package:bukidlink/widgets/productinfo/ProductInfoAppBar.dart';
import 'package:bukidlink/widgets/productinfo/ProductImageCard.dart';
import 'package:bukidlink/widgets/productinfo/ProductHeaderWithQuantity.dart';
import 'package:bukidlink/widgets/productinfo/ProductDetailsCard.dart';
import 'package:bukidlink/widgets/productinfo/ProductReviewsSection.dart';
import 'package:bukidlink/widgets/productinfo/RecommendedProductsSection.dart';
import 'package:bukidlink/widgets/productinfo/BottomActionBar.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

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

  int _quantity = _minQuantity;
  late double _totalPrice;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
  }

  void _handleQuantityChanged(int quantity) {
    setState(() {
      _quantity = quantity;
      _totalPrice = widget.product.price * quantity;
    });
  }

  void _handleAddToBasket() {
    SnackBarHelper.showSnackBar(
      context,
      icon: Icons.check_circle,
      message: 'Added $_quantity x ${widget.product.name} to basket',
    );

    // TODO: Implement basket functionality
    debugPrint(
      'Added to basket: ${widget.product.name} x $_quantity = PHP $_totalPrice',
    );
  }

  void _handleCartPressed() {
    SnackBarHelper.showSnackBar(
      context,
      icon: Icons.shopping_cart,
      message: 'Cart feature coming soon!',
      backgroundColor: AppColors.HEADER_GRADIENT_START,
    );

    // TODO: Navigate to cart page
  }

  void _handleCheckout() {
    SnackBarHelper.showSnackBar(
      context,
      icon: Icons.payment,
      message:
          'Proceeding to checkout with $_quantity x ${widget.product.name}',
    );

    // TODO: Implement checkout functionality
    debugPrint(
      'Checkout: ${widget.product.name} x $_quantity = PHP $_totalPrice',
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendedProducts =
        ProductData.getProductsByCategory(widget.product.category)
            .where((p) => p.id != widget.product.id)
            .take(_recommendedProductsLimit)
            .toList();

    final sampleReviews = ReviewData.getSampleReviews();

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
            ProductImageCard(
              imagePath: widget.product.imagePath,
              category: widget.product.category,
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
            ),
            ProductReviewsSection(
              reviews: sampleReviews,
              onViewAll: () => SnackBarHelper.showSnackBar(
                context,
                icon: Icons.rate_review,
                message: 'View all reviews feature coming soon!',
              ),
            ),
            RecommendedProductsSection(products: recommendedProducts),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        totalPrice: _totalPrice,
        quantity: _quantity,
        onAddToBasket: _handleAddToBasket,
        onCheckout: _handleCheckout,
      ),
    );
  }
}
