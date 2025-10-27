import 'package:flutter/material.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';

class AllReviewsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String productName;

  const AllReviewsAppBar({
    super.key,
    required this.productName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => PageNavigator().goBack(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: AppTextStyles.SECTION_TITLE.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Text(
            productName,
            style: AppTextStyles.PRODUCT_CATEGORY.copyWith(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
    );
  }
}
