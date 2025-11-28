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
        final product = Product.fromDocument(doc);
        if (product.isVisible) {
          products.add(product);
        }
      }
      // Update cache
      _productsCache = products;
    } catch (e) {
      print('Error fetching products: $e');
    }

    // Always return the products list (empty if error occurred)
    return products;
  }

  /// Returns a stream of visible products from Firestore that updates in
  /// real-time when the `products` collection changes.
  Stream<List<Product>> streamProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      final products = <Product>[];
      for (var doc in snapshot.docs) {
        final product = Product.fromDocument(doc);
        if (product.isVisible) products.add(product);
      }
      // update cache on each snapshot
      _productsCache = products;
      return products;
    });
  }

  /// Fetches the average rating for visible products belonging to the
  /// farm identified by [farmName]. Returns `null` when no ratings are
  /// available or an error occurs.
  Future<double?> fetchAverageRatingForFarm({required String farmName}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('farm_name', isEqualTo: farmName)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      double sum = 0.0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final prod = Product.fromDocument(doc);
        if (prod.isVisible && prod.rating != null) {
          sum += prod.rating!;
          count += 1;
        }
      }

      if (count == 0) return null;
      return sum / count;
    } catch (e) {
      print('Error fetching average rating for farm: $e');
      return null;
    }
  }

  /// Fetches up to [limit] visible products for the given [farmId],
  /// ordered by `created_at` descending when available.
  Future<List<Product>> fetchProductsByFarm({
    required String farmId,
    int limit = 5,
  }) async {
    List<Product> products = [];
    try {
      // Perform a simple single-field query to avoid requiring a composite index.
      // We'll query by `farm_id` only, then filter `isVisible` and sort by
      // `created_at` on the client side.
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('farm_id', isEqualTo: farmId)
          .get();

      // If no results, it's possible `farm_id` is stored as a DocumentReference.
      // Try that as a fallback.
      if (snapshot.docs.isEmpty && farmId.isNotEmpty) {
        final farmRef = _firestore.collection('farms').doc(farmId);
        final altSnapshot = await _firestore
            .collection('products')
            .where('farm_id', isEqualTo: farmRef)
            .get();
        snapshot = altSnapshot;
      }

      // Map docs to Product + created_at timestamp for client-side filtering/sorting
      final List<MapEntry<Product, DateTime>> withDates = [];
      for (var doc in snapshot.docs) {
        final prod = Product.fromDocument(doc);
        final data = doc.data() as Map<String, dynamic>;
        final rawCreated = data['created_at'];
        DateTime created;
        if (rawCreated is Timestamp) {
          created = rawCreated.toDate();
        } else if (rawCreated is String) {
          created =
              DateTime.tryParse(rawCreated) ??
              DateTime.fromMillisecondsSinceEpoch(0);
        } else {
          created = DateTime.fromMillisecondsSinceEpoch(0);
        }

        if (prod.isVisible) {
          withDates.add(MapEntry(prod, created));
        }
      }

      // Sort descending by created date and apply the requested limit
      withDates.sort((a, b) => b.value.compareTo(a.value));
      products = withDates.take(limit).map((e) => e.key).toList();

      // Merge results into cache: replace existing entries or append.
      for (var p in products) {
        final index = _productsCache.indexWhere((c) => c.id == p.id);
        if (index != -1) {
          _productsCache[index] = p;
        } else {
          _productsCache.add(p);
        }
      }
    } catch (e) {
      print('Error fetching products by farm: $e');
    }

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
