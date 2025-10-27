import 'package:flutter/material.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/widgets/allreviews/AllReviewsAppBar.dart';
import 'package:bukidlink/widgets/allreviews/ReviewRatingSummary.dart';
import 'package:bukidlink/widgets/allreviews/ReviewSortFilterSection.dart';
import 'package:bukidlink/widgets/allreviews/ReviewListSection.dart';
import 'package:bukidlink/widgets/allreviews/ReviewEmptyState.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class AllReviewsPage extends StatefulWidget {
  final List<ProductReview> reviews;
  final Product product;

  const AllReviewsPage({
    super.key,
    required this.reviews,
    required this.product,
  });

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  String _sortBy = 'recent';
  bool _showVerifiedOnly = false;
  late List<ProductReview> _filteredReviews;

  @override
  void initState() {
    super.initState();
    _filteredReviews = widget.reviews;
    _applySortAndFilter();
  }

  void _applySortAndFilter() {
    setState(() {
      // Filter
      _filteredReviews = widget.reviews.where((review) {
        if (_showVerifiedOnly && !review.isVerifiedPurchase) {
          return false;
        }
        return true;
      }).toList();

      // Sort
      switch (_sortBy) {
        case 'recent':
          break;
        case 'rating_high':
          _filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'rating_low':
          _filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
          break;
      }
    });
  }

  void _handleSortChanged(String newSort) {
    setState(() {
      _sortBy = newSort;
      _applySortAndFilter();
    });
  }

  void _handleFilterChanged(bool newValue) {
    setState(() {
      _showVerifiedOnly = newValue;
      _applySortAndFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: AllReviewsAppBar(productName: widget.product.name),
      body: _filteredReviews.isEmpty
          ? ReviewEmptyState(isFiltered: _showVerifiedOnly)
          : ListView(
              children: [
                ReviewRatingSummary(reviews: widget.reviews),
                ReviewSortFilterSection(
                  sortBy: _sortBy,
                  showVerifiedOnly: _showVerifiedOnly,
                  onSortChanged: _handleSortChanged,
                  onFilterChanged: _handleFilterChanged,
                ),
                const SizedBox(height: 8),
                ReviewListSection(reviews: _filteredReviews),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

