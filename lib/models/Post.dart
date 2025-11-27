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
  return Post(
    id: doc.id,
    textContent: data['textContent'] ?? '',
    imageContent: data['imageContent'] ?? '',
    createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    posterID : data['posterID'] ?? '',
  );
}

  /// Convert model to JSON (for saving or sending)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textContent': textContent,
      'imageContent': imageContent,
      'posterID': posterID,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Copy with updated fields (useful when marking as read)
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
      posterID : posterID ?? this.posterID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
