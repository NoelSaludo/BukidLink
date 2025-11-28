import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:bukidlink/services/cloudinary_service.dart';

/// A reusable service for handling image picking operations
/// Provides methods for selecting images from camera or gallery
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the specified source
  /// Returns the file path if successful, null otherwise
  Future<String?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image != null) {
        // Upload picked file to Cloudinary and return the secure URL
        try {
          final File file = File(image.path);
          final String? uploadedUrl = await CloudinaryService().uploadFile(
            file,
          );
          return uploadedUrl;
        } catch (e) {
          debugPrint('Failed to upload image to Cloudinary: $e');
          return null;
        }
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
      return null;
    } catch (e) {
      debugPrint('Unexpected error picking image: $e');
      return null;
    }
  }

  /// Pick an image from the gallery
  Future<String?> pickFromGallery({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    return pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Pick an image from the camera
  Future<String?> pickFromCamera({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    return pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Save the picked image to app's document directory
  /// Returns the new file path
  Future<String?> saveImageToAppDirectory(String imagePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
      final String newPath = path.join(appDir.path, 'profile_images', fileName);

      // Create directory if it doesn't exist
      final Directory profileDir = Directory(path.dirname(newPath));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Copy the file
      final File sourceFile = File(imagePath);
      final File newFile = await sourceFile.copy(newPath);

      return newFile.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// Delete an image file from the given path
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Show a bottom sheet to choose between camera and gallery
  /// Returns the selected image path
  Future<String?> showImageSourceBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const ImageSourceBottomSheet();
      },
    );
  }
}

/// Reusable bottom sheet widget for selecting image source
class ImageSourceBottomSheet extends StatelessWidget {
  const ImageSourceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ImagePickerService imagePickerService = ImagePickerService();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Change Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Use your camera'),
              onTap: () async {
                HapticFeedback.lightImpact();
                // Pick and upload; return the Cloudinary URL to the caller
                final String? imageUrl = await imagePickerService
                    .pickFromCamera(
                      imageQuality: 85,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                if (context.mounted) {
                  Navigator.pop(context, imageUrl);
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Colors.green),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Select from your photos'),
              onTap: () async {
                HapticFeedback.lightImpact();
                final String? imageUrl = await imagePickerService
                    .pickFromGallery(
                      imageQuality: 85,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                if (context.mounted) {
                  Navigator.pop(context, imageUrl);
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.red),
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
