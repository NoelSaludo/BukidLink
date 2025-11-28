import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';

import 'package:http/http.dart' as http;

/// CloudinaryService
///
/// Singleton service for performing unsigned uploads to Cloudinary and
/// building image URLs. Reads configuration from `.env` using `flutter_dotenv`.
///
/// Expected entries in `.env` (case-insensitive keys used here):
/// - `CLOUDINARY_NAME` (required)
/// - `CLOUDINARY_UPLOAD_PRESET` (recommended for unsigned uploads)
/// - `CLOUDINARY_URL` (optional)
///
/// NOTE: Do NOT place `API_SECRET` in the client for signed operations. For
/// delete or signed uploads, implement a server-side signing endpoint.
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal() {
    _cloudName = dotenv.env['CLOUDINARY_NAME'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
      cloudName: _cloudName,
    );
  }

  late final String _cloudName;
  late final String _uploadPreset;

  /// Uploads a file to Cloudinary using unsigned upload.
  /// Returns the secure URL of the uploaded image on success, null on failure.
  Future<String?> uploadFile(File file) async {
    if (_cloudName.isEmpty) {
      debugPrint('CloudinaryService: CLOUDINARY_NAME is empty');
      throw Exception('CLOUDINARY_NAME is not configured');
    }
    if (_uploadPreset.isEmpty) {
      debugPrint('CloudinaryService: CLOUDINARY_UPLOAD_PRESET is empty');
      throw Exception(
        'CLOUDINARY_UPLOAD_PRESET is not configured (required for unsigned uploads)',
      );
    }

    if (!await file.exists()) {
      debugPrint(
        'CloudinaryService: file does not exist at path: ${file.path}',
      );
      throw Exception('File does not exist: ${file.path}');
    }

    // Correct endpoint: /image/upload (was missing 'image' and caused 400)
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final streamed = await request.send();
      final respStr = await streamed.stream.bytesToString();

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        try {
          final data = json.decode(respStr) as Map<String, dynamic>;
          return data['secure_url'] as String?;
        } catch (e) {
          debugPrint('CloudinaryService: failed decoding success response: $e');
          return null;
        }
      }

      // Non-success: try to extract Cloudinary error message
      String errorMessage = 'Status ${streamed.statusCode}';
      try {
        final data = json.decode(respStr);
        if (data is Map && data['error'] != null) {
          final err = data['error'];
          if (err is Map && err['message'] != null) {
            errorMessage = err['message'].toString();
          } else {
            errorMessage = err.toString();
          }
        } else {
          errorMessage = respStr;
        }
      } catch (_) {
        errorMessage = respStr;
      }

      debugPrint('Cloudinary upload failed: $errorMessage');
      throw Exception('Cloudinary upload failed: $errorMessage');
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      rethrow;
    }
  }
}
