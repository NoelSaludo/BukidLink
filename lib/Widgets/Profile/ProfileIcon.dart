import 'dart:io';
import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProfileIcon({
    super.key,
    required this.imageUrl,
    this.size = 80, // default size if not provided
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (imageUrl.isEmpty) {
      imageProvider = const AssetImage('assets/images/default_profile.png');
    } else if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      imageProvider = NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      imageProvider = AssetImage(imageUrl);
    } else if (imageUrl.startsWith('/') || imageUrl.contains(':\\')) {
      final file = File(imageUrl);
      imageProvider = file.existsSync()
          ? FileImage(file)
          : const AssetImage('assets/images/default_profile.png');
    } else {
      // Treat as asset with sanitization to avoid double 'images/' segments
      final sanitized = imageUrl.replaceFirst(RegExp(r'^/+'), '');
      String assetPath;
      if (sanitized.startsWith('images/')) {
        assetPath = 'assets/' + sanitized; // images/... -> assets/images/...
      } else {
        assetPath = 'assets/images/' + sanitized;
      }
      imageProvider = AssetImage(assetPath);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    );
  }
}
