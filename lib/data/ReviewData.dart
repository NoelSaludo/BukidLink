import 'package:bukidlink/models/ProductReview.dart';

class ReviewData {
  ReviewData._();

  /// Get sample reviews for a product
  /// fetch from an API/database
  static List<ProductReview> getSampleReviews() {
    return [
      ProductReview(
        userName: 'Maria Santos',
        userAvatar: 'MS',
        rating: 5.0,
        comment:
            'Excellent quality! Fresh and very tasty. Will definitely order again.',
        date: DateTime.now().subtract(Duration(days: 2)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Juan Dela Cruz',
        userAvatar: 'JD',
        rating: 4.5,
        comment: 'Good product, delivered fresh. Packaging was also great.',
        date: DateTime.now().subtract(Duration(days: 7)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Anna Reyes',
        userAvatar: 'AR',
        rating: 4.0,
        comment: 'Nice quality, worth the price. Delivery was on time.',
        date: DateTime.now().subtract(Duration(days: 14)),
        isVerifiedPurchase: false,
      ),
      ProductReview(
        userName: 'Roberto Garcia',
        userAvatar: 'RG',
        rating: 5.0,
        comment:
            'Amazing freshness! You can really taste the difference. The farm-to-table quality is evident. Highly recommend!',
        date: DateTime.now().subtract(Duration(days: 3)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Carmen Flores',
        userAvatar: 'CF',
        rating: 4.5,
        comment:
            'Very satisfied with my purchase. The product arrived in perfect condition and exceeded my expectations.',
        date: DateTime.now().subtract(Duration(days: 5)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Pedro Martinez',
        userAvatar: 'PM',
        rating: 3.5,
        comment:
            'Good quality overall but the delivery took longer than expected. Product itself is fresh though.',
        date: DateTime.now().subtract(Duration(days: 7)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Lisa Aquino',
        userAvatar: 'LA',
        rating: 5.0,
        comment:
            'Best purchase ever! The quality is outstanding and the price is very reasonable. Will order regularly from now on.',
        date: DateTime.now().subtract(Duration(days: 7)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Miguel Torres',
        userAvatar: 'MT',
        rating: 4.0,
        comment:
            'Great product from a local farm. Supporting local farmers while getting quality produce. Win-win!',
        date: DateTime.now().subtract(Duration(days: 14)),
        isVerifiedPurchase: false,
      ),
      ProductReview(
        userName: 'Sofia Mendoza',
        userAvatar: 'SM',
        rating: 4.5,
        comment:
            'Very fresh and well-packaged. My family loved it. The taste is much better than what you get from supermarkets.',
        date: DateTime.now().subtract(Duration(days: 14)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Ricardo Bautista',
        userAvatar: 'RB',
        rating: 5.0,
        comment:
            'Exceptional quality! You can tell these are grown with care. The flavor is incredible and the freshness is unmatched.',
        date: DateTime.now().subtract(Duration(days: 21)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Elena Cruz',
        userAvatar: 'EC',
        rating: 4.0,
        comment:
            'Solid product at a fair price. Delivery was smooth and the customer service was helpful when I had questions.',
        date: DateTime.now().subtract(Duration(days: 21)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Antonio Ramos',
        userAvatar: 'AR',
        rating: 4.5,
        comment:
            'Really impressed with the quality. Fresh, clean, and exactly as described. Would definitely recommend to friends.',
        date: DateTime.now().subtract(Duration(days: 30)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Grace Villanueva',
        userAvatar: 'GV',
        rating: 5.0,
        comment:
            'Perfect! This is exactly what I was looking for. The farm is doing an excellent job maintaining quality standards.',
        date: DateTime.now().subtract(Duration(days: 30)),
        isVerifiedPurchase: true,
      ),
      ProductReview(
        userName: 'Daniel Santiago',
        userAvatar: 'DS',
        rating: 3.5,
        comment:
            'Decent quality, though I\'ve had better. Still good value for money and the delivery was professional.',
        date: DateTime.now().subtract(Duration(days: 30)),
        isVerifiedPurchase: false,
      ),
      ProductReview(
        userName: 'Patricia Castillo',
        userAvatar: 'PC',
        rating: 4.5,
        comment:
            'Love supporting local farms and the quality speaks for itself. Fresh, delicious, and sustainably grown.',
        date: DateTime.now().subtract(Duration(days: 30)),
        isVerifiedPurchase: true,
      ),
    ];
  }

  /// Get reviews for a specific product
  /// filter by product ID
  static List<ProductReview> getReviewsForProduct(String productId) {
    // TODO: Implement actual product-specific review fetching
    return getSampleReviews();
  }
}
