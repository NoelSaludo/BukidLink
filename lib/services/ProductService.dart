import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _productsCache = [];

  Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();

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
  Future<void> addReviewToProduct(
    String productId,
    ProductReview review,
  ) async {
    try {
      DocumentReference productRef = _firestore
          .collection('products')
          .doc(productId);

      await productRef.update({
        'reviews': FieldValue.arrayUnion([review.toJson()]),
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
      DocumentReference productRef = _firestore
          .collection('products')
          .doc(productId);

      await productRef.update({'stock_count': newStock});

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

  Future<List<ProductReview>> fetchProductReviews(String productId) async {
    List<ProductReview> reviews = [];
    try {
      QuerySnapshot reviewSnapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .get();

      reviews = reviewSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductReview.fromDocument(data);
      }).toList();
    } catch (e) {
      print('Error fetching product reviews: $e');
    }

    return reviews;
  }

  List<Product> getCachedProducts() {
    return _productsCache;
  }

  // Adds a new product document to Firestore and updates local cache.
  Future<void> addNewProduct(Product product) async {
    try {
      final CollectionReference productsColl = _firestore.collection(
        'products',
      );

      DocumentReference docRef;
      if (product.id.isNotEmpty) {
        docRef = productsColl.doc(product.id);
        await docRef.set(product.toJson());
      } else {
        docRef = productsColl.doc();
        final json = product.toJson();
        json['id'] = docRef.id;
        await docRef.set(json);
      }

      // Ensure there's an (initially empty) reviews subcollection by not adding any docs.
      // Note: Firestore only materializes subcollections when they have documents.

      // Update cache: add product (use the id from docRef)
      final added = product.copyWith(id: docRef.id);
      _productsCache.add(added);
    } catch (e) {
      print('Error adding new product: $e');
    }
  }

  // Replaces the product document (by id) in Firestore and updates cache entry.
  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) {
      print('Error updating product: product id is empty');
      return;
    }

    try {
      final DocumentReference productRef = _firestore
          .collection('products')
          .doc(product.id);
      await productRef.set(product.toJson());

      // Update cache: replace existing product with same id
      int index = _productsCache.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _productsCache[index] = product;
      } else {
        _productsCache.add(product);
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  // Replace a review in the product's `reviews` subcollection and update cache.
  Future<void> updateReview(String productId, ProductReview review) async {
    if (productId.isEmpty) {
      print('Error updating review: productId is empty');
      return;
    }

    try {
      final DocumentReference productRef = _firestore
          .collection('products')
          .doc(productId);

      // If review has an id, use it as the document id. Otherwise try to find matching review doc.
      // Since ProductReview doesn't include an 'id' field, match existing review documents
      // by a combination of fields (userName, comment, date). If a match is found, replace it.
      final QuerySnapshot qs = await productRef
          .collection('reviews')
          .where('userName', isEqualTo: review.userName)
          .where('comment', isEqualTo: review.comment)
          .get();

      if (qs.docs.isNotEmpty) {
        // If multiple matches, try to match by date string as well
        DocumentSnapshot? matchDoc;
        for (var d in qs.docs) {
          final data = d.data() as Map<String, dynamic>;
          final dateStr = data['date']?.toString();
          if (dateStr != null && dateStr == review.date.toIso8601String()) {
            matchDoc = d;
            break;
          }
        }

        final target = matchDoc ?? qs.docs.first;
        await target.reference.set(review.toJson());
      } else {
        // No matching review found, add as new document
        await productRef.collection('reviews').add(review.toJson());
      }

      // Update cache: locate product and replace review in its reviews list
      int pIndex = _productsCache.indexWhere((p) => p.id == productId);
      if (pIndex != -1) {
        final existing = _productsCache[pIndex];
        final updatedReviews = <ProductReview>[];
        if (existing.reviews != null) {
          updatedReviews.addAll(existing.reviews!);
        }

        final rIndex = updatedReviews.indexWhere(
          (r) =>
              r.userName == review.userName &&
              r.comment == review.comment &&
              r.date == review.date,
        );
        if (rIndex != -1) {
          updatedReviews[rIndex] = review;
        } else {
          updatedReviews.add(review);
        }

        _productsCache[pIndex] = existing.copyWith(reviews: updatedReviews);
      }
    } catch (e) {
      print('Error updating review: $e');
    }
  }
}
