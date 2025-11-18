import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/pages/farmer/FarmerStorePage.dart';

class FarmerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const FarmerBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigateToPage(BuildContext context, int index) {
    // Don't navigate if already on the current page
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const FarmerStorePage();
        break;
      case 1:
        // TODO: Implement Trade Page
        page = const FarmerStorePage(); // Placeholder
        break;
      case 2:
        // TODO: Implement News Feed Page
        page = const FarmerStorePage(); // Placeholder
        break;
      case 3:
        // TODO: Implement Order Management Page
        page = const FarmerStorePage(); // Placeholder
        break;
      default:
        page = const FarmerStorePage();
    }

    PageNavigator().goToWithTransition(
      context,
      page,
      PageTransitionType.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.HEADER_GRADIENT_START,
            AppColors.HEADER_GRADIENT_END,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.storefront_outlined,
                Icons.storefront,
                'Store',
                0,
              ),
              _buildNavItem(
                context,
                Icons.sync_alt_outlined,
                Icons.sync_alt,
                'Trades',
                1,
              ),
              _buildNavItem(
                context,
                Icons.article_outlined,
                Icons.article,
                'Feed',
                2,
              ),
              _buildNavItem(
                context,
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Orders',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToPage(context, index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: Colors.white,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: isSelected
                  ? AppTextStyles.FARMER_NAV_SELECTED
                  : AppTextStyles.FARMER_NAV_UNSELECTED,
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
