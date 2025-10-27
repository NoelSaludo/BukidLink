import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class CartQuantityControls extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int minQuantity;
  final int? maxQuantity;

  const CartQuantityControls({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 1,
    this.maxQuantity,
  });

  @override
  State<CartQuantityControls> createState() => _CartQuantityControlsState();
}

class _CartQuantityControlsState extends State<CartQuantityControls> {
  void _increment() {
    if (widget.maxQuantity == null || widget.quantity < widget.maxQuantity!) {
      HapticFeedback.lightImpact();
      widget.onQuantityChanged(widget.quantity + 1);
    }
  }

  void _decrement() {
    if (widget.quantity > widget.minQuantity) {
      HapticFeedback.lightImpact();
      widget.onQuantityChanged(widget.quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.quantity > widget.minQuantity;
    final canIncrement =
        widget.maxQuantity == null || widget.quantity < widget.maxQuantity!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.INACTIVE_GREY, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: canDecrement ? _decrement : null,
            enabled: canDecrement,
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.INACTIVE_GREY,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.quantity}',
              style: AppTextStyles.QUANTITY_TEXT.copyWith(fontSize: 16),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.INACTIVE_GREY,
          ),
          _buildButton(
            icon: Icons.add,
            onPressed: canIncrement ? _increment : null,
            enabled: canIncrement,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primaryGreen : AppColors.HINT_TEXT_GREY,
        ),
      ),
    );
  }
}
