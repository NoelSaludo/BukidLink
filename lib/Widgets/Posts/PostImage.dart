import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/widgets/common/BouncingDotsLoader.dart';

class PostImage extends StatelessWidget {
  final String? imagePath; // allow null
  final double? width;
  final double? height;
  final BoxFit fit;

  const PostImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Return nothing if imagePath is null or empty
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if the path is a URL
    if (imagePath!.toLowerCase().startsWith('http')) {
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.withOpacity(0.05),
            child: const Center(
              child: BouncingDotsLoader(
                color: AppColors.ACCENT_LIME,
                size: 8.0,
              ),
            ),
          );
        },
      );
    }

    // Fallback to asset image
    final assetPath = 'assets/images/' + imagePath!;
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
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