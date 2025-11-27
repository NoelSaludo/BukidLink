import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

class PostIcon extends StatelessWidget {
  final String? imageUrl; // nullable to handle missing profile images
  final VoidCallback onTapped;

  const PostIcon({
    super.key,
    required this.onTapped,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is null or empty, show placeholder
    final isValidUrl = imageUrl != null && imageUrl!.isNotEmpty;

    return InkWell(
      onTap: onTapped,
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 24 * 2,
          height: 24 * 2,
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
      width: 24 * 2,
      height: 24 * 2,
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
      width: 24 * 2,
      height: 24 * 2,
      decoration: BoxDecoration(
        color: AppColors.ACCENT_LIME.withOpacity(0.2),
      ),
      child: CircleAvatar(
            radius: 22,
            backgroundImage: const AssetImage('assets/images/default_profile.png'),
          ),
    );
  }
}
