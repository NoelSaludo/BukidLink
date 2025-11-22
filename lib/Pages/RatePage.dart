import 'package:flutter/material.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/ProductReview.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/SnackBarHelper.dart';
import 'package:bukidlink/services/OrderService.dart';
import 'package:uuid/uuid.dart';


class RatePage extends StatefulWidget {
  final Product product;
  final double initialRating;

  const RatePage({
    super.key,
    required this.product,
    this.initialRating = 0.0,
  });

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  late int _rating;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating.toInt();
  }

  void _submitReview() {
    if (_rating == 0) {
      SnackBarHelper.showError(context, 'Please select a rating');
      return;
    }

    final newReview = ProductReview(
      id: const Uuid().v4(),
      userName: 'Anonymous',
      userAvatar: 'A',
      rating: _rating.toDouble(),
      comment: _reviewController.text.trim(),
      date: 'Just now',
      isVerifiedPurchase: true,
    );

    widget.product.reviews?.add(newReview);
    widget.product.tempRating = _rating.toDouble();

    final orderService = OrderService.shared;
    for (final order in orderService.orders) {
      if (order.items.any((i) => i.product?.id == widget.product.id)) {
        orderService.checkAndMarkCompleted(order);
        break;
      }
    }

    SnackBarHelper.showSuccess(context, 'Thank you for your feedback!');
    Navigator.pop(context);
  }


  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 32,
      ),
      onPressed: () {
        setState(() => _rating = index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.APP_BACKGROUND,
      appBar: AppBar(
        title: Text(
          'Rate ${widget.product.name}',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.HEADER_GRADIENT_START,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: 'Write your review here...',
                hintStyle: TextStyle(fontFamily: 'Outfit'),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Outfit'),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.HEADER_GRADIENT_START,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Post Review',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
