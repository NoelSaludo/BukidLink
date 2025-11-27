import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/home/CategoryCard.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': 'assets/icons/fruits-3d.png', 'label': 'Fruits'},
      {'icon': 'assets/icons/vegetables-3d.png', 'label': 'Vegetables'},
      {'icon': 'assets/icons/grains-3d.png', 'label': 'Grains'},
      {'icon': 'assets/icons/livestock-3d.png', 'label': 'Livestock'},
      {'icon': 'assets/icons/dairy-3d.png', 'label': 'Dairy'},
      {'icon': 'assets/icons/more-3d.png', 'label': 'More'},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: categories.map((category) {
        return CategoryCard(
          iconPath: category['icon']!,
          label: category['label']!,
        );
      }).toList(),
    );
  }
}
