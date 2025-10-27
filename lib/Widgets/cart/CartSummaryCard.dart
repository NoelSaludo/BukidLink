import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/PesoText.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;
  final VoidCallback onCheckout;
  final bool isProcessing;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.onCheckout,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow('Subtotal', subtotal),
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery Fee', deliveryFee),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildTotalRow(),
              const SizedBox(height: 16),
              _buildCheckoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.FONT_FAMILY,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.TEXT_SECONDARY,
          ),
        ),
        PesoText(
          amount: amount,
          decimalPlaces: 2,
          style: const TextStyle(
            fontFamily: AppTextStyles.FONT_FAMILY,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.DARK_TEXT,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontFamily: AppTextStyles.FONT_FAMILY,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.DARK_TEXT,
          ),
        ),
        PesoText(
          amount: total,
          decimalPlaces: 2,
          style: const TextStyle(
            fontFamily: AppTextStyles.FONT_FAMILY,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : onCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.HINT_TEXT_GREY,
        ),
        child: isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontFamily: AppTextStyles.FONT_FAMILY,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
