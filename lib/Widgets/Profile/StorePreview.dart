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
              // Title + optional farm subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store', style: AppTextStyles.PRODUCT_NAME_HEADER),
                    const SizedBox(height: 4),
                    if (_farmName != null)
                      Text(
                        _farmName!,
                        style: AppTextStyles.farmName,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Primary store action as a compact elevated button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: _openStore,
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('View Store', style: AppTextStyles.BUTTON_TEXT),
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
            const Icon(Icons.error_outline, size: 40, color: AppColors.ERROR_RED),
            const SizedBox(height: 12),
            Text('Couldn\'t load store', style: AppTextStyles.SECTION_TITLE),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'We\'re having trouble fetching the products. Please check your connection and try again.',
                style: AppTextStyles.EMPTY_STATE_SUBTITLE,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: AppTextStyles.BUTTON_TEXT),
            ),
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
              size: 56,
              color: AppColors.TEXT_SECONDARY.withOpacity(0.35),
            ),
            const SizedBox(height: 12),
            Text(
              _farmName != null ? 'No products from $_farmName yet' : 'No products yet',
              style: AppTextStyles.EMPTY_STATE_TITLE,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                'The seller hasn\'t listed items in the store. Tap below to view the full storefront.',
                style: AppTextStyles.EMPTY_STATE_SUBTITLE,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text('Visit Store', style: AppTextStyles.BUTTON_TEXT),
            ),
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
