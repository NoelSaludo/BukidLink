class Product {
  final String id;
  final String name;
  final String farmName;
  final String imagePath;
  final String category;
  final double price; // Numeric price for sorting/filtering
  final String? description; // Product description
  final double? rating; // Product rating (0-5)
  final String? unit; // e.g., "kg", "piece", "bundle"
  final int? reviewCount; // Number of reviews
  final String? availability; // e.g., "In Stock", "Limited", "Out of Stock"
  final List<ProductReview>? reviews; // Product reviews

  Product({
    required this.id,
    required this.name,
    required this.farmName,
    required this.imagePath,
    required this.category,
    required this.price,
    this.description,
    this.rating,
    this.unit,
    this.reviewCount,
    this.availability,
    this.reviews,
  });
}

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
