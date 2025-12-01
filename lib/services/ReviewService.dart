import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  static final ReviewService shared = ReviewService._internal();
  ReviewService._internal();
  factory ReviewService() => shared;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => UserService.currentUser?.id ?? _auth.currentUser?.uid;

  // Submit a review for a product
  Future<bool> submitReview({
    required String productId,
    required double rating,
    required String comment,
    required String orderId,
  }) async {
    if (_currentUserId == null) {
      debugPrint('User not logged in');
      return false;
    }

    try {
      final user = UserService.currentUser;
      final userName = user != null
          ? '${user.firstName} ${user.lastName}'.trim()
          : 'Anonymous';
      final userAvatar = user?.username.isNotEmpty == true
          ? user!.username[0].toUpperCase()
          : 'A';

      debugPrint('   Submitting review for product: $productId');
      debugPrint('   Rating: $rating');
      debugPrint('   Order: $orderId');

      // Create review document in products/{productId}/reviews subcollection
      final reviewRef = _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc();

      final reviewData = {
        'user_id': _currentUserId,
        'username': userName,
        'user_avatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'date': FieldValue.serverTimestamp(),
        'is_verified_purchase': true,
        'order_id': orderId,
        'created_at': FieldValue.serverTimestamp(),
      };

      await reviewRef.set(reviewData);

      debugPrint(' Review saved: ${reviewRef.id}');

      // Update product's aggregate rating
      await _updateProductRating(productId);

      // Mark this product as rated in the order
      await _markProductAsRatedInOrder(orderId, productId, rating);

      return true;
    } catch (e) {
      debugPrint(' Error submitting review: $e');
      return false;
    }
  }

  // Update product's aggregate rating
  Future<void> _updateProductRating(String productId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        debugPrint('   No reviews yet for product $productId');
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      int count = 0;

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
        totalRating += rating;
        count++;
      }

      final averageRating = count > 0 ? totalRating / count : 0.0;

      // Update product document
      await _firestore.collection('products').doc(productId).update({
        'rating': averageRating,
        'review_count': count,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint(' Updated product rating: $averageRating ($count reviews)');
    } catch (e) {
      debugPrint(' Error updating product rating: $e');
    }
  }

  // Mark product as rated in order
  Future<void> _markProductAsRatedInOrder(
      String orderId,
      String productId,
      double rating,
      ) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) {
        debugPrint('   Order $orderId not found');
        return;
      }

      final data = orderDoc.data() as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>?) ?? [];

      // Update the specific item to mark it as rated
      final updatedItems = items.map((item) {
        if (item['product_id'] == productId) {
          return {
            ...item,
            'rated': true,
            'rating': rating,
          };
        }
        return item;
      }).toList();

      await _firestore.collection('orders').doc(orderId).update({
        'items': updatedItems,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('  Marked product $productId as rated in order $orderId');

      // Check if all items are rated
      final allRated = updatedItems.every((item) => item['rated'] == true);

      if (allRated) {
        debugPrint('  All items rated! Moving order to completed...');
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'completed',
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint(' Order $orderId marked as completed');
      } else {
        debugPrint(' Still waiting for other items to be rated');
      }
    } catch (e) {
      debugPrint(' Error marking product as rated: $e');
    }
  }

  // Fetch reviews for a product
  Future<List<ProductReview>> fetchReviews(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ProductReview.fromDocument(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(' Error fetching reviews: $e');
      return [];
    }
  }

  // Stream reviews for a product (real-time)
  Stream<List<ProductReview>> reviewsStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductReview.fromDocument(doc.data()))
        .toList());
  }

  // Check if user has reviewed a product in a specific order
  Future<bool> hasUserReviewedProduct(String productId, String orderId) async {
    if (_currentUserId == null) return false;

    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .where('user_id', isEqualTo: _currentUserId)
          .where('order_id', isEqualTo: orderId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint(' Error checking review status: $e');
      return false;
    }
  }
}