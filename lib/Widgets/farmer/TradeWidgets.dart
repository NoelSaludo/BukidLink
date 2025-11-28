import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';
import '../../models/TradeModels.dart';

class TradeDashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const TradeDashboardButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.green),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TradeListingCard extends StatelessWidget {
  final TradeListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onOfferPressed;

  const TradeListingCard({
    required this.listing,
    this.onTap,
    this.onOfferPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.ACCENT_LIME.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ProductImage(
                      imagePath: listing.image.isNotEmpty ? listing.image : 'assets/images/default_cover_photo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.name,
                          style: AppTextStyles.STORE_PRODUCT_NAME.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          listing.quantity,
                          style: AppTextStyles.STORE_PRODUCT_PRICE.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(height: 1, color: AppColors.ACCENT_LIME.withOpacity(0.2)),

            // Info row: Offers and Preferred
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Row(
                children: [
                  // Offers count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Offers', style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('${listing.offersCount}', style: AppTextStyles.STORE_PRODUCT_INFO_LABEL.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  // Preferred trades shown as chips or count
                  if (listing.preferredTrades.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: listing.preferredTrades.length > 3 ? 3 : listing.preferredTrades.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final val = listing.preferredTrades[idx];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.CARD_BACKGROUND,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                val,
                                style: AppTextStyles.BODY_TEXT.copyWith(color: AppColors.DARK_TEXT, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Action Buttons: render Offer only when a handler is provided
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  if (onOfferPressed != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onOfferPressed?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: AppColors.HEADER_GRADIENT_START, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.HEADER_GRADIENT_START),
                        label: Text('Offer', style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(color: AppColors.HEADER_GRADIENT_START, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onTap?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: AppColors.ERROR_RED, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.visibility, size: 16, color: AppColors.ERROR_RED),
                        label: Text('View', style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(color: AppColors.ERROR_RED, fontSize: 13)),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onTap?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: AppColors.ERROR_RED, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.visibility, size: 16, color: AppColors.ERROR_RED),
                        label: Text('View', style: AppTextStyles.STORE_ACTION_BUTTON.copyWith(color: AppColors.ERROR_RED, fontSize: 13)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
