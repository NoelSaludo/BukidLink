import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:flutter/material.dart';
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
    return const Center(child: CircularProgressIndicator());
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
