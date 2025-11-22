import 'package:flutter/foundation.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Add a product to cart
  Future<void> addProductToCart(Product product, int amount) async {
    if (_currentUserId == null) throw Exception('User not logged in');

    try {
      final cartRef = _firestore.collection('carts').doc(_currentUserId);
      final productRef = cartRef.collection('products').doc(product.id);

      final productDoc = await productRef.get();

      if (productDoc.exists) {
        await _updateExistingProduct(productRef, productDoc, amount);
      } else {
        await _addNewProduct(cartRef, productRef, product, amount);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding product to cart: $e');
      rethrow;
    }
  }

  Future<void> _updateExistingProduct(
    DocumentReference productRef,
    DocumentSnapshot productDoc,
    int amount,
  ) async {
    final data = productDoc.data() as Map<String, dynamic>;
    final currentAmount = data['amount'] ?? 0;
    final newAmount = currentAmount + amount;

    await productRef.update({
      'amount': newAmount,
    });

    await _updateCartMetadata();
  }

  Future<void> _addNewProduct(
    DocumentReference cartRef,
    DocumentReference productRef,
    Product product,
    int amount,
  ) async {
    final batch = _firestore.batch();

    final cartDoc = await cartRef.get();
    if (!cartDoc.exists) {
      batch.set(cartRef, {
        'user_id': _currentUserId,
        'total_cost': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    batch.set(productRef, {
      'product_id': product.id,
      'amount': amount,
    });

    await batch.commit();
    await _updateCartMetadata();
  }

  // Remove a product from cart
  Future<void> removeProductFromCart(String productId) async {
    if (_currentUserId == null) throw Exception('User not logged in');

    try {
      final productRef = _firestore
          .collection('carts')
          .doc(_currentUserId)
          .collection('products')
          .doc(productId);

      await productRef.delete();
      await _updateCartMetadata();

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing product from cart: $e');
      rethrow;
    }
  }

  // Update product amount
  Future<void> updateProductAmount(String productId, int newAmount) async {
    if (_currentUserId == null) throw Exception('User not logged in');

    try {
      if (newAmount <= 0) {
        await removeProductFromCart(productId);
        return;
      }

      final productRef = _firestore
          .collection('carts')
          .doc(_currentUserId)
          .collection('products')
          .doc(productId);

      await productRef.update({'amount': newAmount});
      await _updateCartMetadata();

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating product amount: $e');
      rethrow;
    }
  }

  Future<void> _updateCartMetadata() async {
    if (_currentUserId == null) return;

    final cartRef = _firestore.collection('carts').doc(_currentUserId);
    await cartRef.update({
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.amount);

  double get subtotal => _items.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

  double get deliveryFee => _items.isEmpty ? 0.0 : 50.0;

  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(Product product, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].amount += quantity;
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          product: product,
          amount: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.productId == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.productId == cartItemId);
    if (index >= 0) {
      _items[index].amount = newQuantity;
      notifyListeners();
    }
  }

  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.productId == cartItemId);
    if (index >= 0) {
      _items[index].amount++;
      notifyListeners();
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.productId == cartItemId);
    if (index >= 0) {
      if (_items[index].amount > 1) {
        _items[index].amount--;
        notifyListeners();
      } else {
        removeItem(cartItemId);
      }
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  CartItem? getItem(String cartItemId) {
    try {
      return _items.firstWhere((item) => item.productId == cartItemId);
    } catch (e) {
      return null;
    }
  }

  bool hasProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getProductQuantity(String productId) {
    try {
      final item = _items.firstWhere(
        (item) => item.productId == productId,
      );
      return item.amount;
    } catch (e) {
      return 0;
    }
  }
}
