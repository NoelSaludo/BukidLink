import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

/// A widget that displays an amount with the peso currency symbol (₱)
/// using the Roboto Condensed font for the symbol.
class PesoText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final int decimalPlaces;
  final String? suffix;

  const PesoText({
    super.key,
    required this.amount,
    this.style,
    this.decimalPlaces = 2,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    final amountStr = amount.toStringAsFixed(decimalPlaces);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '₱',
            style: AppTextStyles.PESO_SYMBOL.copyWith(
              fontSize: baseStyle.fontSize,
              color: baseStyle.color,
              fontWeight: baseStyle.fontWeight,
              height: baseStyle.height,
            ),
          ),
          TextSpan(
            text: amountStr,
            style: baseStyle,
          ),
          if (suffix != null)
            TextSpan(
              text: suffix,
              style: baseStyle,
            ),
        ],
      ),
    );
  }
}
