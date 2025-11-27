import 'package:flutter/material.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Resolve the incoming profileID into an actual farm id string.
      // profileID may be a user id, a farm id, or a farm name depending on
      // where the navigation originated. Try to resolve in this order:
      // 1. Treat as a user id -> fetch user -> use user's farmId
      // 2. Treat as a farm document id -> check farms collection
      // 3. Treat as a farm name -> query farms by name
      String? resolvedFarmId;
      String? displayFarmName;

      // 1) Try as user id
      final user = await UserService().getUserById(widget.profileID);
      if (user != null) {
        resolvedFarmId = user.farmId?.id;
        displayFarmName = user.farmId?.id ?? widget.profileID;
        debugPrint(
          'StorePreview: resolved profileID as user -> farmId=$resolvedFarmId',
        );
      }

      // 2) If still null, try as farm document id
      if (resolvedFarmId == null) {
        final farmDoc = await FirebaseFirestore.instance
            .collection('farms')
            .doc(widget.profileID)
            .get();
        if (farmDoc.exists) {
          resolvedFarmId = farmDoc.id;
          final data = farmDoc.data();
          displayFarmName = data != null
              ? (data['name']?.toString() ?? farmDoc.id)
              : farmDoc.id;
          debugPrint(
            'StorePreview: resolved profileID as farm doc -> farmId=$resolvedFarmId',
          );
        }
      }

      // 3) If still null, try to find farm by name
      if (resolvedFarmId == null) {
        final qs = await FirebaseFirestore.instance
            .collection('farms')
            .where('name', isEqualTo: widget.profileID)
            .limit(1)
            .get();
        if (qs.docs.isNotEmpty) {
          resolvedFarmId = qs.docs.first.id;
          final data = qs.docs.first.data();
          displayFarmName = data['name']?.toString() ?? resolvedFarmId;
          debugPrint(
            'StorePreview: resolved profileID by farm name -> farmId=$resolvedFarmId',
          );
        }
      }

      // Fallback: use the raw profileID as farm id (may be incorrect but keeps behavior)
      final farmId = resolvedFarmId ?? widget.profileID;
      _farmName = displayFarmName ?? widget.profileID;

      debugPrint(
        'StorePreview: querying products with farmId=$farmId (displayName=$_farmName)',
      );

      final products = await _productService.fetchProductsByFarm(
        farmId: farmId,
        limit: 5,
      );

      setState(() {
        _products = products;
        _isLoading = false;
        debugPrint('Loaded ${products.length} products for farm $farmId');
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
          // Increase height to accommodate ProductCard (compact layout)
          // ProductCard compact uses a 140px image plus content; 260 gives
          // enough room to avoid the 54px bottom overflow previously observed.
          SizedBox(height: 280, child: _buildContent()),
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
