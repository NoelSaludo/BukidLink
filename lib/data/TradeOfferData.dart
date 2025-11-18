import 'package:bukidlink/models/TradeOffer.dart';
import 'package:bukidlink/data/ProductData.dart';

class TradeOfferData {
  static List<TradeOffer> getAllTradeOffers() {
    final products = ProductData.getAllProducts();
    
    return [
      // Trade 1: My Mango for Dragon Fruit
      TradeOffer(
        id: '1',
        myProduct: products.firstWhere((p) => p.id == '1'), // Mango
        offerProduct: products.firstWhere((p) => p.id == '4'), // Dragon Fruit
        myQuantity: 5,
        offerQuantity: 2,
        offeredBy: 'Juan Dela Cruz',
        offeredAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'pending',
      ),
      // Trade 2: My Mango for Bitter Melon
      TradeOffer(
        id: '2',
        myProduct: products.firstWhere((p) => p.id == '1'), // Mango
        offerProduct: products.firstWhere((p) => p.id == '11'), // Bitter Melon
        myQuantity: 5,
        offerQuantity: 4,
        offeredBy: 'Maria Santos',
        offeredAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'pending',
      ),
      // Trade 3: My Potato for Papaya
      TradeOffer(
        id: '3',
        myProduct: products.firstWhere((p) => p.id == '10'), // Potato
        offerProduct: products.firstWhere((p) => p.id == '6'), // Papaya
        myQuantity: 3,
        offerQuantity: 3,
        offeredBy: 'Pedro Garcia',
        offeredAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
      ),
    ];
  }
  
  static List<TradeOffer> getPendingTradeOffers() {
    return getAllTradeOffers()
        .where((offer) => offer.status == 'pending')
        .toList();
  }
}
