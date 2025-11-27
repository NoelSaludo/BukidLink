import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostIcon extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTapped;
  final String? posterId;
  const PostIcon({
    super.key,
    required this.imageUrl,
    required this.onTapped,
    this. posterId,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.toLowerCase().startsWith('http')) {
    return InkWell(
      onTap: onTapped,
      child: Container(
    width: 50, // desired width
    height: 50, // desired height
    child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey.withOpacity(0.05),
            child: const Center(
              child: BouncingDotsLoader(
                color: AppColors.ACCENT_LIME,
                size: 8.0,
              ),
            ),
          );
        },
      )
  ),
    );
  }
  return InkWell(
    onTap: onTapped,
    child: Image.asset(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    ),
    );
  }
    Widget _buildErrorWidget() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.ACCENT_LIME,
        size: 32,
      ),
    );
  }
}