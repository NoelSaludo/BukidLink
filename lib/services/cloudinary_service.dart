import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  CloudinaryService._();

  static final CloudinaryService _instance = CloudinaryService._();
  static CloudinaryService get instance => _instance;

  /// Convenience static method that uploads a local image file and returns
  /// the `secure_url` of the uploaded image on success.
  ///
  /// - [imagePath]: local filesystem path to the image file.
  /// - [uploadPreset]: optional unsigned upload preset; if omitted the service
  ///   will try to read `CLOUDINARY_UPLOAD_PRESET` from `.env`.
  /// - [folder]: optional Cloudinary folder to place the uploaded image in.
  ///
  /// Throws an [Exception] on failure.
  static Future<String> uploadImage(
    String imagePath, {
    String? uploadPreset,
    String? folder,
  }) {
    return _instance._uploadImage(
      imagePath,
      uploadPreset: uploadPreset,
      folder: folder,
    );
  }

  /// Build a Cloudinary delivery URL for a given `publicId`.
  /// If [transformation] is provided it is inserted into the URL (raw
  /// transformation string expected, e.g. `w_400,h_300,c_fill`). If [format]
  /// is provided it will be appended (e.g. `jpg`).
  static String getImageUrl(
    String publicId, {
    String? transformation,
    String? format,
  }) {
    final name = dotenv.env['CLOUDINARY_NAME'] ?? dotenv.env['cloudinary_name'];
    if (name == null || name.isEmpty) {
      throw Exception('CLOUDINARY_NAME is not set in .env');
    }

    final buffer = StringBuffer();
    buffer.write('https://res.cloudinary.com/');
    buffer.write(name);
    buffer.write('/image/upload/');
    if (transformation != null && transformation.isNotEmpty) {
      buffer.write('$transformation/');
    }
    buffer.write(publicId);
    if (format != null && format.isNotEmpty) {
      buffer.write('.$format');
    }
    return buffer.toString();
  }

  Future<String> _uploadImage(
    String imagePath, {
    String? uploadPreset,
    String? folder,
  }) async {
    final cloudName =
        dotenv.env['CLOUDINARY_NAME'] ?? dotenv.env['cloudinary_name'];
    if (cloudName == null || cloudName.isEmpty) {
      throw Exception('CLOUDINARY_NAME is not set in .env');
    }

    final preset =
        uploadPreset ??
        dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ??
        dotenv.env['cloudinary_upload_preset'];
    if (preset == null || preset.isEmpty) {
      throw Exception(
        'CLOUDINARY_UPLOAD_PRESET is not set in .env and no uploadPreset provided',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $imagePath');
    }

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = preset;
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    final multipartFile = await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(multipartFile);

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      String body = resp.body;
      String message = 'Cloudinary upload failed (status: ${resp.statusCode})';
      try {
        final json = jsonDecode(body);
        if (json is Map && json['error'] != null) {
          message = '${message}: ${json['error']}';
        }
      } catch (_) {}
      throw Exception(message);
    }

    final Map<String, dynamic> bodyJson = jsonDecode(resp.body);
    final secureUrl = bodyJson['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary upload did not return secure_url');
    }

    return secureUrl;
  }
}
