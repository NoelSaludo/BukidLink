import 'package:bukidlink/models/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final Product? product; // Optional - may need to be fetched separately
  int amount;

  CartItem({
    required this.productId,
    this.product,
    required this.amount,
  });

  double get totalPrice => (product?.price ?? 0) * amount;

  // Factory to create CartItem from Firestore document
  static CartItem fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CartItem(
      productId: data['product_id'] ?? '',
      amount: _parseAmount(data['amount']),
      product: null, // Product needs to be fetched separately using productId
    );
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  CartItem copyWith({
    String? productId,
    Product? product,
    int? amount,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'amount': amount,
    };
  }
}
