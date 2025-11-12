import 'ProductReview.dart';

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
  final String availability; // e.g., "In Stock", "Limited", "Out of Stock"
  final int stockCount; // Remaining stock quantity
  final List<ProductReview>? reviews; // Product reviews
  double tempRating = 0.0;


  Product({
    required this.id,
    required this.name,
    required this.farmName,
    required this.imagePath,
    required this.category,
    required this.price,
    required this.availability,
    required this.stockCount,
    this.description,
    this.rating,
    this.unit,
    this.reviewCount,
    this.reviews,
  });
}
