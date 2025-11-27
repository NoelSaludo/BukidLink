import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductCard.dart';

class RecommendedProductsSection extends StatelessWidget {
  final List<Product> products;

  const RecommendedProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              'You May Also Like',
              style: AppTextStyles.SECTION_TITLE,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ProductCard(
                  product: products[index],
                  layout: ProductCardLayout.compact,
                  showAddButton: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
