import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isVerifiedPurchase;

  ProductReview({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.isVerifiedPurchase = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }

  static ProductReview fromDocument(Map<String, dynamic> data) {
    Timestamp stamp = Timestamp.now();
    return ProductReview(
      userName: data['username'] ?? '',
      userAvatar: data['user_avatar'] ?? '',
      rating: double.tryParse(data['rating'].toString()) ?? 0.0,
      comment: data['comment'] ?? '',
      date: data['date'] is DateTime
          ? data['date']
          : data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate()
              : DateTime.tryParse(data['date'].toString()) ?? stamp.toDate(),
      isVerifiedPurchase: data['is_verified_purchase'] ?? false,
    );
  }
}