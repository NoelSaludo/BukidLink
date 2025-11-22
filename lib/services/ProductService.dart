import 'package:bukidlink/models/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _productsCache = [];

  Future<List<Product>> fetchProducts() async {
    List<Product> products = [];
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('products').get();

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

  List<Product> getCachedProducts() {
    return _productsCache;
  }

}