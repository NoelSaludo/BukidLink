/// Model class for handling image data with content-type and base64 encoding
class Image {
  final String contentType;
  final String base64;

  Image({
    required this.contentType,
    required this.base64,
  });

  /// Create Image from JSON
  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      contentType: json['contentType'] as String,
      base64: json['base64'] as String,
    );
  }

  /// Convert Image to JSON
  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType,
      'base64': base64,
    };
  }

  /// Get the data URI for the image (can be used in img src)
  String get dataUri => 'data:$contentType;base64,$base64';

  /// Common content types
  static const String contentTypeJpeg = 'image/jpeg';
  static const String contentTypePng = 'image/png';
  static const String contentTypeGif = 'image/gif';
  static const String contentTypeWebp = 'image/webp';
  static const String contentTypeSvg = 'image/svg+xml';

  /// Check if the image is a specific type
  bool get isJpeg => contentType == contentTypeJpeg || contentType == 'image/jpg';
  bool get isPng => contentType == contentTypePng;
  bool get isGif => contentType == contentTypeGif;
  bool get isWebp => contentType == contentTypeWebp;
  bool get isSvg => contentType == contentTypeSvg;

  /// Create a copy with updated fields
  Image copyWith({
    String? contentType,
    String? base64,
  }) {
    return Image(
      contentType: contentType ?? this.contentType,
      base64: base64 ?? this.base64,
    );
  }

  @override
  String toString() {
    return 'Image(contentType: $contentType, base64Length: ${base64.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Image &&
        other.contentType == contentType &&
        other.base64 == base64;
  }

  @override
  int get hashCode => contentType.hashCode ^ base64.hashCode;
}

