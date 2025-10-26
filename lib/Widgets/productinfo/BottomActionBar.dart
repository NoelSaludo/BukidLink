import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/productinfo/AddToBasketButton.dart';
import 'package:bukidlink/widgets/productinfo/CheckoutButton.dart';

class BottomActionBar extends StatelessWidget {
  final double totalPrice;
  final int quantity;
  final VoidCallback onAddToBasket;
  final VoidCallback onCheckout;

  const BottomActionBar({
    super.key,
    required this.totalPrice,
    required this.quantity,
    required this.onAddToBasket,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.APP_BACKGROUND,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AddToBasketButton(
                    totalPrice: totalPrice,
                    quantity: quantity,
                    onPressed: onAddToBasket,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CheckoutButton(
                    totalPrice: totalPrice,
                    quantity: quantity,
                    onPressed: onCheckout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
