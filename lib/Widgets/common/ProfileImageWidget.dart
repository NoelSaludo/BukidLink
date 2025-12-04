import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

/// A reusable profile image widget that displays images from assets, network, or file
/// Supports placeholder for missing images
class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final IconData placeholderIcon;

  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.size = 100,
    this.showBorder = true,
    this.borderColor = Colors.white,
    this.borderWidth = 4,
    this.onTap,
    this.showEditBadge = false,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipOval(
              child: Container(
                width: size,
                height: size,
                color: Colors.white,
                child: _buildImageWidget(),
              ),
            ),
            if (showEditBadge)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(size * 0.08),
                  decoration: BoxDecoration(
                    color: AppColors.ACCENT_LIME,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: size * 0.16,
                    color: AppColors.DARK_TEXT,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if it's a file path (starts with / or contains :\ for Windows)
    if (imageUrl!.startsWith('/') || imageUrl!.contains(':\\')) {
      final File imageFile = File(imageUrl!);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // Check if it's an asset
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Otherwise, try to load as network image
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryGreen,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Default: treat as asset with assets/images/ prefix but sanitize incoming
    final sanitized = imageUrl!.trim().replaceFirst(RegExp(r'^/+'), '');
    String assetPath;
    if (sanitized.startsWith('assets/')) {
      assetPath = sanitized;
    } else if (sanitized.startsWith('images/')) {
      assetPath = 'assets/' + sanitized; // images/... -> assets/images/...
    } else {
      assetPath = 'assets/images/' + sanitized;
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.ACCENT_LIME.withOpacity(0.3),
      child: Center(
        child: Icon(
          placeholderIcon,
          size: size * 0.5,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
