import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

class PostIcon extends StatelessWidget {
  final String? imageUrl; // nullable to handle missing profile images
  final VoidCallback onTapped;
  final double radius;

  const PostIcon({
    super.key,
    required this.onTapped,
    this.imageUrl,
    this.radius = 24.0, // default radius
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is null or empty, show placeholder
    final isValidUrl = imageUrl != null && imageUrl!.isNotEmpty;

    return InkWell(
      onTap: onTapped,
      borderRadius: BorderRadius.circular(radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.withOpacity(0.05),
          child: isValidUrl
              ? _buildNetworkImage(imageUrl!)
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: BouncingDotsLoader(
            color: AppColors.ACCENT_LIME,
            size: 8.0,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.ACCENT_LIME,
        size: 32,
      ),
    );
  }
}
