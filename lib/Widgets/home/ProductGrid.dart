import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bukidlink/widgets/common/ProductCard.dart';

class ProductGrid extends StatelessWidget {
  ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: ProductService().fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }

        final products = snapshot.data;
        if (products == null || products.isEmpty) {
          return _buildEmpty();
        }

        return _buildGrid(products);
      },
    );
  }

  Widget _buildLoading() {
    return _buildShimmerGrid();
  }

  Widget _buildShimmerGrid() {
    // show 6 shimmer placeholders matching the grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image placeholder
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(color: Colors.grey.shade300),
                  ),
                ),
                // content placeholder
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: MediaQuery.of(context).size.width * 0.3,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.25,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(Object? error) {
    return Center(child: Text('Error loading products: ${error ?? "Unknown"}'));
  }

  Widget _buildEmpty() {
    return const Center(child: Text('No products available'));
  }

  Widget _buildGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductItem(context, products[index]);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return ProductCard(
      product: product,
      layout: ProductCardLayout.grid,
      showAddButton: true,
    );
  }
}
