import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/common/ProductCard.dart';
import 'package:bukidlink/data/ProductData.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Get popular products from ProductData
    final products = ProductData.getPopularProducts(limit: 10);

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
        return ProductCard(
          product: products[index],
          layout: ProductCardLayout.grid,
          showAddButton: true,
        );
      },
    );
  }
}
