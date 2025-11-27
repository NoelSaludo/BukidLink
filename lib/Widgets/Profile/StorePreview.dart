import 'package:flutter/material.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/Widgets/common/ProductCard.dart';
import 'package:bukidlink/Pages/StorePage.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class StorePreview extends StatefulWidget {
  final String profileID;

  const StorePreview({super.key, required this.profileID});

  @override
  State<StorePreview> createState() => _StorePreviewState();
}

class _StorePreviewState extends State<StorePreview> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  List<Product> _products = [];
  String? _farmName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Attempt to use profileID as farmName. If your app exposes a UserService
      // to resolve farm details, replace this with that resolution.
      final farmName = widget.profileID;
      _farmName = farmName;

      final products = await _productService.fetchProductsByFarm(
        farmName: farmName,
        limit: 5,
      );

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openStore() {
    if (_farmName == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StorePage(farmName: _farmName!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Store', style: AppTextStyles.PRODUCT_NAME_HEADER),
              IconButton(
                tooltip: 'Open Store',
                onPressed: _openStore,
                icon: const Icon(Icons.storefront_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 200, child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Unable to load store',
              style: AppTextStyles.PRODUCT_NAME_HEADER,
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadPreview, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 48,
              color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            const Text('No products yet'),
            const SizedBox(height: 6),
            TextButton(onPressed: _openStore, child: const Text('View Store')),
          ],
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final p = _products[index];
        return ProductCard(
          product: p,
          layout: ProductCardLayout.compact,
          showAddButton: true,
        );
      },
    );
  }
}
