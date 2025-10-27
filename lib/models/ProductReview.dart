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
}
