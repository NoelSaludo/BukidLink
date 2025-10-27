import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/widgets/common/CartIconWithBadge.dart';
import 'package:bukidlink/pages/CartPage.dart';

class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String farmName;

  const StoreAppBar({
    super.key,
    required this.farmName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleCartPressed(BuildContext context) {
    PageNavigator().goToAndKeepWithTransition(
      context,
      const CartPage(),
      PageTransitionType.slideFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.HEADER_GRADIENT_START,
              AppColors.HEADER_GRADIENT_END,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => PageNavigator().goBack(context),
      ),
      title: Text(
        'Store',
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CartIconWithBadge(
            onPressed: () => _handleCartPressed(context),
          ),
        ),
      ],
    );
  }
}
