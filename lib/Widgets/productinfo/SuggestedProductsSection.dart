import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductCard.dart';

class SuggestedProductsSection extends StatelessWidget {
  final List<Product> products;
  final String? excludeProductId;

  const SuggestedProductsSection({
    super.key,
    required this.products,
    this.excludeProductId,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) => p.id != excludeProductId).toList();

    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            'No AI suggestions',
            style: AppTextStyles.SECTION_TITLE.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Text(
              'Suggested For You',
              style: AppTextStyles.SECTION_TITLE,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filtered[index],
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
