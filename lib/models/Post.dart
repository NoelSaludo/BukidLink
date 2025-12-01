import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String textContent;
  final String imageContent;
  final DateTime createdAt;
  final String posterID;

  Post({
    required this.id,
    required this.textContent,
    required this.imageContent,
    required this.createdAt,
    required this.posterID,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final raw = data['created_at'] ?? data['createdAt'];
    DateTime parsedCreatedAt;
    if (raw == null) {
      parsedCreatedAt = DateTime.now();
    } else if (raw is Timestamp) {
      parsedCreatedAt = raw.toDate();
    } else if (raw is DateTime) {
      parsedCreatedAt = raw;
    } else if (raw is String) {
      parsedCreatedAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Post(
      id: doc.id,
      textContent: data['textContent'] ?? '',
      imageContent: data['imageContent'] ?? '',
      createdAt: parsedCreatedAt,
      posterID: data['posterID'] ?? '',
    );
  }

  /// Convert model to JSON (for saving or sending) — use Firestore `Timestamp`
  Map<String, dynamic> toJson() {
    return {
      'textContent': textContent,
      'imageContent': imageContent,
      'posterID': posterID,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  Post copyWith({
    String? textContent,
    String? imageContent,
    String? posterID,
    DateTime? createdAt,
  }) {
    return Post(
      id: id,
      textContent: textContent ?? this.textContent,
      imageContent: imageContent ?? this.imageContent,
      posterID: posterID ?? this.posterID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}