class Post {
  final String id;
  final String textContent;
  final String imageContent;
  final DateTime timestamp;
  final String posterID;

  Post({
    required this.id,
    required this.textContent,
    required this.imageContent,
    DateTime? timestamp,
    required this.posterID,
  }) : timestamp = timestamp ?? DateTime.now();


  /// Convert model to JSON (for saving or sending)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'textContent': textContent,
      'imageContent': imageContent,
      'posterID': posterID,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Copy with updated fields (useful when marking as read)
  Post copyWith({
    String? textContent,
    String? imageContent,
    String? posterID,
    DateTime? timestamp,
  }) {
    return Post(
      id: id,
      textContent: textContent ?? this.textContent,
      imageContent: imageContent ?? this.imageContent,
      posterID : posterID ?? this.posterID,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
