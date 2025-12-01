import 'package:bukidlink/models/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String productId;
  final Product? product;
  int amount;
  bool rated;
  double? rating;

  CartItem({
    required this.id,
    required this.productId,
    this.product,
    required this.amount,
    this.rated = false,
    this.rating,
  });

  double get totalPrice => (product?.price ?? 0) * amount;

  // Factory to create CartItem from Firestore document
  static CartItem fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CartItem(
      id: doc.id,
      productId: data['product_id'] ?? '',
      amount: _parseAmount(data['amount']),
      rated: data['rated'] ?? false,
      rating: data['rating']?.toDouble(),
      product: null,
    );
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'product_id': productId,
      'amount': amount,
      'rated': rated,
      'rating': rating,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? amount,
    bool? rated,
    double? rating,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      amount: amount ?? this.amount,
      rated: rated ?? this.rated,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'amount': amount,
      'rated': rated,
      'rating': rating,
      'product': product?.toJson(),
    };
  }

  // Create from Firestore
  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      id: data['id'] ?? '',
      productId: data['product_id'] ?? '',
      product: data['product'] != null
          ? Product.fromFirestore(data['product'] as Map<String, dynamic>)
          : null,
      amount: _parseAmount(data['amount']),
      rated: data['rated'] ?? false,
      rating: data['rating']?.toDouble(),
    );
  }
}