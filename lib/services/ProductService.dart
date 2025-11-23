import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _productsCache = [];

  Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('products').get();

      for (var doc in snapshot.docs) {
        products.add(Product.fromDocument(doc));
      }
      // Update cache
      _productsCache = products;

    } catch (e) {
      print('Error fetching products: $e');
    }

    // Always return the products list (empty if error occurred)
    return products;
  }

  // Accept a ProductReview and persist it as a Map to Firestore.
  Future<void> addReviewToProduct(String productId, ProductReview review) async {
    try {
      DocumentReference productRef =
          _firestore.collection('products').doc(productId);

      await productRef.update({
        'reviews': FieldValue.arrayUnion([review.toJson()])
      });

      // Update cache if product exists in cache by replacing the product with a copy
      int index = _productsCache.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final existing = _productsCache[index];
        final updatedReviews = <ProductReview>[];
        if (existing.reviews != null) {
          updatedReviews.addAll(existing.reviews!);
        }
        updatedReviews.add(review);

        _productsCache[index] = existing.copyWith(reviews: updatedReviews);
      }

    } catch (e) {
      print('Error adding review to product: $e');
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      DocumentReference productRef =
          _firestore.collection('products').doc(productId);

      await productRef.update({
        'stock_count': newStock
      });

      // Update cache if product exists in cache by replacing the product with a copy
      int index = _productsCache.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final existing = _productsCache[index];
        _productsCache[index] = existing.copyWith(stockCount: newStock);
      }

    } catch (e) {
      print('Error updating product stock: $e');
    }
  }

  List<Product> getCachedProducts() {
    return _productsCache;
  }

}