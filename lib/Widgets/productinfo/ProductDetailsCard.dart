import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
// Navigation now uses named routes; PageNavigator/ProfilePage import not required here.
import 'package:bukidlink/Widgets/Profile/FollowButton.dart';
import 'package:bukidlink/services/FarmService.dart';

class ProductDetailsCard extends StatelessWidget {
  final String description;
  final String farmName;
  final String? farmId;

  const ProductDetailsCard({
    super.key,
    required this.description,
    required this.farmName,
    this.farmId,
  });

  Future<void> _navigateToProfile(BuildContext context) async {
    HapticFeedback.lightImpact();
    // Resolve the farm owner (user) id when we have a farmId and pass
    // the userId to the named route so navigation remains consistent.
    String? argumentToPass;
    if (farmId != null && farmId!.isNotEmpty) {
      final userId = await FarmService().getUserIdForFarmId(farmId!);
      argumentToPass = userId ?? farmId;
    } else {
      argumentToPass = farmName;
    }

    Navigator.of(
      context,
    ).pushNamed('/farmerProfile', arguments: argumentToPass);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Details', style: AppTextStyles.SECTION_TITLE),
          const SizedBox(height: 12),
          Text(description, style: AppTextStyles.DESCRIPTION_TEXT),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.ACCENT_LIME.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.HEADER_GRADIENT_START,
                          AppColors.HEADER_GRADIENT_END,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sold by',
                          style: AppTextStyles.SELLER_LABEL_MEDIUM,
                        ),
                        const SizedBox(height: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmName,
                              style: AppTextStyles.SELLER_NAME_LARGE,
                            ),
                            const SizedBox(height: 8),
                            if (farmId != null)
                              FollowButton(farmId: farmId!, width: 120),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.TEXT_SECONDARY.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
