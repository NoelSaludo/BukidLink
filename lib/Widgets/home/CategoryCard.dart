import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/pages/CategoryPage.dart';

class CategoryCard extends StatelessWidget {
  final String iconPath;
  final String label;

  const CategoryCard({super.key, required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        PageNavigator().goToSleek(
          context,
          CategoryPage(categoryName: label, categoryIcon: iconPath),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 54, height: 54, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.categoryLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
