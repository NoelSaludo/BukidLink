import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

/// Reusable unit selector widget for product selling
class UnitSelector extends StatelessWidget {
  final String? selectedUnit;
  final Function(String) onUnitSelected;
  final String? customUnit;
  final Function(String)? onCustomUnitChanged;
  final TextEditingController? customUnitController;

  const UnitSelector({
    super.key,
    required this.selectedUnit,
    required this.onUnitSelected,
    this.customUnit,
    this.onCustomUnitChanged,
    this.customUnitController,
  });

  static const List<String> units = ['Whole', 'Kilogram', 'Liter', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...units.map((unit) {
          final isSelected = selectedUnit == unit;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onUnitSelected(unit);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.BORDER_GREY.withOpacity(0.2),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.BORDER_GREY,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            unit,
                            style: AppTextStyles.BODY_MEDIUM.copyWith(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.DARK_TEXT
                                  : AppColors.TEXT_SECONDARY,
                            ),
                          ),
                        ),
                        if (isSelected && unit != 'Other')
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: AppColors.primaryGreen,
                          ),
                      ],
                    ),
                    if (unit == 'Other' && isSelected) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customUnitController,
                        onChanged: onCustomUnitChanged,
                        decoration: InputDecoration(
                          hintText: 'Enter unit',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.HINT_TEXT_GREY.withOpacity(0.7),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.BORDER_GREY.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.BORDER_GREY.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        style: AppTextStyles.BODY_MEDIUM.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
