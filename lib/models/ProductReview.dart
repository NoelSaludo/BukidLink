class ProductReview {
  final String id;
  final String userName;
  final String userAvatar; // Initials or image path
  final double rating;
  final String comment;
  final String date; // e.g., "2 days ago"
  final bool isVerifiedPurchase;

  ProductReview({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerifiedPurchase = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }

  ProductReview fromDocument(Map<String, dynamic> data) {
    return ProductReview(
      id: data['id'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      rating: double.tryParse(data['rating'].toString()) ?? 0.0,
      comment: data['comment'] ?? '',
      date: data['date'] ?? '',
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
    );
  }
}
