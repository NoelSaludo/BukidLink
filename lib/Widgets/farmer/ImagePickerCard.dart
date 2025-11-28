import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/ProductImage.dart';

/// Reusable image picker card widget for product images
class ImagePickerCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ImagePickerCard({
    super.key,
    this.imagePath,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.BACKGROUND_WHITE,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: imagePath != null && imagePath!.isNotEmpty
                ? AppColors.primaryGreen.withOpacity(0.4)
                : AppColors.BORDER_GREY.withOpacity(0.2),
            width: imagePath != null && imagePath!.isNotEmpty ? 2 : 1.5,
          ),
          boxShadow: [
            if (imagePath != null && imagePath!.isNotEmpty)
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: imagePath != null && imagePath!.isNotEmpty
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildImage(),
            ),
            if (onRemove != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.ERROR_RED,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            // Edit overlay hint
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to change',
                      style: AppTextStyles.BODY_MEDIUM.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.12),
                    AppColors.HEADER_GRADIENT_END.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Product Image',
              style: AppTextStyles.BODY_MEDIUM.copyWith(
                color: AppColors.DARK_TEXT,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to upload from gallery or camera',
              style: AppTextStyles.BODY_MEDIUM.copyWith(
                color: AppColors.TEXT_SECONDARY,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath!.toLowerCase().startsWith('http') || imagePath!.startsWith('assets/')) {
      return ProductImage(
        imagePath: imagePath!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(imagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
