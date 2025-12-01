import 'ProductReview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Product {
  final String id;
  final String name;
  final String farmerId;
  final String farmName;
  final String imagePath;
  final String category;
  final double price;
  final String? description;
  final double? rating;
  final String? unit;
  final int? reviewCount;
  final String availability;
  final int stockCount;
  final List<ProductReview>? reviews;
  double tempRating = 0.0;
  final String? farmId;
  final bool isVisible;

  Product({
    required this.id,
    required this.name,
    required this.farmerId,
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
    this.farmId,
    this.isVisible = true,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'farmerId': farmerId,
      'farmName': farmName,
      'imagePath': imagePath,
      'category': category,
      'price': price,
      'description': description,
      'rating': rating,
      'unit': unit,
      'reviewCount': reviewCount,
      'availability': availability,
      'stockCount': stockCount,
      'tempRating': tempRating,
    };
  }

  static Product fromDocument(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Stock/amount may be stored under different keys depending on the document
    final dynamic rawAmount =
        data['amount'] ?? data['stock_count'] ?? data['stockCount'] ?? 0;
    final int stockCount = rawAmount is int
        ? rawAmount
        : int.tryParse(rawAmount?.toString() ?? '0') ?? 0;

    // Price/cost may be stored under 'cost' or 'price' and may be numeric or string
    final dynamic rawPrice = data['cost'] ?? data['price'];
    final double price = rawPrice != null
        ? double.tryParse(rawPrice.toString()) ?? 0.0
        : 0.0;

    // Image path may be 'image_url' or 'imagePath'. Use default asset if missing.
    final String rawImage = (data['image_url'] ?? data['imagePath'] ?? '')
        .toString();
    final String imagePath = rawImage.isNotEmpty
        ? rawImage
        : 'assets/images/default_cover_photo.png';

    // Rating may not exist or may be stored as string/number
    final dynamic rawRating = data['rating'];
    final double? rating = rawRating != null
        ? double.tryParse(rawRating.toString()) ?? 0.0
        : null;

    // Derive availability if it's not explicitly provided
    final String availability =
        (data['availability'] as String?) ??
            (stockCount > 0 ? 'In Stock' : 'Out of Stock');

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmName: data['farm_name'] ?? '',
      farmId: data['farm_id'] is DocumentReference
          ? (data['farm_id'] as DocumentReference).id
          : data['farm_id']?.toString(),
      imagePath: imagePath,
      category: data['category'] ?? '',
      price: price,
      description: data['description'],
      rating: rating,
      unit: data['unit'],
      reviewCount: (data['review_count'] != null)
          ? int.tryParse(data['review_count'].toString())
          : null,
      availability: availability,
      stockCount: stockCount,
      reviews: data['reviews'] != null
          ? (data['reviews'] as List<dynamic>).map((reviewData) {
        final reviewMap = reviewData as Map<String, dynamic>;
        return ProductReview.fromDocument(reviewMap);
      }).toList()
          : null,
      isVisible: data['isVisible'] ?? true,
    );
  }

  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmName: data['farmName'] ?? '',
      imagePath: data['imagePath'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      availability: data['availability'] ?? 'In Stock',
      stockCount: data['stockCount'] ?? 0,
      description: data['description'],
      rating: data['rating']?.toDouble(),
      unit: data['unit'],
      reviewCount: data['reviewCount'],
    )..tempRating = (data['tempRating'] ?? 0).toDouble();
  }

  // Create a modified copy of this Product. Useful for updating cached instances.
  Product copyWith({
    String? id,
    String? name,
    String? farmName,
    String? imagePath,
    String? category,
    double? price,
    String? description,
    double? rating,
    String? unit,
    int? reviewCount,
    String? availability,
    int? stockCount,
    List<ProductReview>? reviews,
    String? farmId,
    bool? isVisible,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      farmerId: this.farmerId,
      farmName: farmName ?? this.farmName,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      price: price ?? this.price,
      availability: availability ?? this.availability,
      stockCount: stockCount ?? this.stockCount,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      unit: unit ?? this.unit,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      farmId: farmId ?? this.farmId,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  // Helper to convert Product to a Map for Firestore since Product model lacks toJson().
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farm_name': farmName,
      'imagePath': imagePath,
      'category': category,
      'price': price,
      'description': description,
      'rating': rating,
      'unit': unit,
      'review_count': reviewCount,
      'availability': availability,
      'stock_count': stockCount,
      'farm_id': farmId,
      'reviews': reviews != null
          ? reviews!.map((r) => r.toJson()).toList()
          : null,
      'isVisible': isVisible,
    };
  }
}