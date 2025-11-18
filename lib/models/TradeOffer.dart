import 'package:bukidlink/models/Product.dart';

class TradeOffer {
  final String id;
  final Product myProduct;
  final Product offerProduct;
  final double myQuantity;
  final double offerQuantity;
  final String offeredBy;
  final DateTime offeredAt;
  final String status; // pending, accepted, declined

  TradeOffer({
    required this.id,
    required this.myProduct,
    required this.offerProduct,
    required this.myQuantity,
    required this.offerQuantity,
    required this.offeredBy,
    required this.offeredAt,
    this.status = 'pending',
  });
}
