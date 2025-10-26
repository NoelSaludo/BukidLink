import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/home/CategoryCard.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': 'assets/icons/fruits.png', 'label': 'Fruits'},
      {'icon': 'assets/icons/vegetables.png', 'label': 'Vegetables'},
      {'icon': 'assets/icons/grains.png', 'label': 'Grains'},
      {'icon': 'assets/icons/livestock.png', 'label': 'Livestock'},
      {'icon': 'assets/icons/dairy.png', 'label': 'Dairy'},
      {'icon': 'assets/icons/more.png', 'label': 'More'},
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

