import 'package:bukidlink/models/ProductReview.dart';

class ReviewData {
  ReviewData._();

  /// Get sample reviews for a product
  /// fetch from an API/database
  static List<ProductReview> getSampleReviews() {
    return [
      ProductReview(
        id: '1',
        userName: 'Maria Santos',
        userAvatar: 'MS',
        rating: 5.0,
        comment:
            'Excellent quality! Fresh and very tasty. Will definitely order again.',
        date: '2 days ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '2',
        userName: 'Juan Dela Cruz',
        userAvatar: 'JD',
        rating: 4.5,
        comment: 'Good product, delivered fresh. Packaging was also great.',
        date: '1 week ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '3',
        userName: 'Anna Reyes',
        userAvatar: 'AR',
        rating: 4.0,
        comment: 'Nice quality, worth the price. Delivery was on time.',
        date: '2 weeks ago',
        isVerifiedPurchase: false,
      ),
      ProductReview(
        id: '4',
        userName: 'Roberto Garcia',
        userAvatar: 'RG',
        rating: 5.0,
        comment:
            'Amazing freshness! You can really taste the difference. The farm-to-table quality is evident. Highly recommend!',
        date: '3 days ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '5',
        userName: 'Carmen Flores',
        userAvatar: 'CF',
        rating: 4.5,
        comment:
            'Very satisfied with my purchase. The product arrived in perfect condition and exceeded my expectations.',
        date: '5 days ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '6',
        userName: 'Pedro Martinez',
        userAvatar: 'PM',
        rating: 3.5,
        comment:
            'Good quality overall but the delivery took longer than expected. Product itself is fresh though.',
        date: '1 week ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '7',
        userName: 'Lisa Aquino',
        userAvatar: 'LA',
        rating: 5.0,
        comment:
            'Best purchase ever! The quality is outstanding and the price is very reasonable. Will order regularly from now on.',
        date: '1 week ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '8',
        userName: 'Miguel Torres',
        userAvatar: 'MT',
        rating: 4.0,
        comment:
            'Great product from a local farm. Supporting local farmers while getting quality produce. Win-win!',
        date: '2 weeks ago',
        isVerifiedPurchase: false,
      ),
      ProductReview(
        id: '9',
        userName: 'Sofia Mendoza',
        userAvatar: 'SM',
        rating: 4.5,
        comment:
            'Very fresh and well-packaged. My family loved it. The taste is much better than what you get from supermarkets.',
        date: '2 weeks ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '10',
        userName: 'Ricardo Bautista',
        userAvatar: 'RB',
        rating: 5.0,
        comment:
            'Exceptional quality! You can tell these are grown with care. The flavor is incredible and the freshness is unmatched.',
        date: '3 weeks ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '11',
        userName: 'Elena Cruz',
        userAvatar: 'EC',
        rating: 4.0,
        comment:
            'Solid product at a fair price. Delivery was smooth and the customer service was helpful when I had questions.',
        date: '3 weeks ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '12',
        userName: 'Antonio Ramos',
        userAvatar: 'AR',
        rating: 4.5,
        comment:
            'Really impressed with the quality. Fresh, clean, and exactly as described. Would definitely recommend to friends.',
        date: '1 month ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '13',
        userName: 'Grace Villanueva',
        userAvatar: 'GV',
        rating: 5.0,
        comment:
            'Perfect! This is exactly what I was looking for. The farm is doing an excellent job maintaining quality standards.',
        date: '1 month ago',
        isVerifiedPurchase: true,
      ),
      ProductReview(
        id: '14',
        userName: 'Daniel Santiago',
        userAvatar: 'DS',
        rating: 3.5,
        comment:
            'Decent quality, though I\'ve had better. Still good value for money and the delivery was professional.',
        date: '1 month ago',
        isVerifiedPurchase: false,
      ),
      ProductReview(
        id: '15',
        userName: 'Patricia Castillo',
        userAvatar: 'PC',
        rating: 4.5,
        comment:
            'Love supporting local farms and the quality speaks for itself. Fresh, delicious, and sustainably grown.',
        date: '1 month ago',
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
