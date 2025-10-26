import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/widgets/home/ProductCard.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock product data
    final products = [
      Product(
        id: '1',
        name: 'Tomato',
        farmName: 'De Castro Farms',
        priceInfo: 'Php 50 per kilo',
        imagePath: 'assets/images/tomato.png',
      ),
      Product(
        id: '2',
        name: 'Eggplant',
        farmName: 'Farmsuenyo',
        priceInfo: 'Php 50 per kilo',
        imagePath: 'assets/images/eggplant.png',
      ),
      Product(
        id: '3',
        name: 'Strawberries',
        farmName: 'Berry Farms',
        priceInfo: 'Php 120 per kilo',
        imagePath: 'assets/images/strawberry.png',
      ),
      Product(
        id: '4',
        name: 'Potato',
        farmName: 'Highland Farms',
        priceInfo: 'Php 45 per kilo',
        imagePath: 'assets/images/potato.png',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

