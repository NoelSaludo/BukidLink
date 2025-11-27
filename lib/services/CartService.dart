import 'package:flutter/foundation.dart';
import 'package:bukidlink/models/CartItem.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductService _productService = ProductService();

  String? get _currentUserId => _auth.currentUser?.uid;

  final List<CartItem> _items = [];

  // Load cart from Firebase
  Future<void> loadCart() async {
    if (_currentUserId == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    try {
      final cartRef = _firestore.collection('carts').doc(_currentUserId);
      final productsSnapshot = await cartRef.collection('products').get();

      _items.clear();

      for (var doc in productsSnapshot.docs) {
        final cartItem = CartItem.fromDocument(doc);
        final product = await _fetchProductById(cartItem.productId);

        if (product != null) {
          _items.add(cartItem.copyWith(product: product));
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<Product?> _fetchProductById(String productId) async {
    try {
      final products = await _productService.fetchProducts();
      return products.firstWhere(
        (p) => p.id == productId,
        orElse: () => products.first,
      );
    } catch (e) {
      debugPrint('Error fetching product $productId: $e');
      return null;
    }
  }

  // Ensure cart document exists for the current user
  Future<void> _ensureCartExists() async {
    if (_currentUserId == null) return;

    final cartRef = _firestore.collection('carts').doc(_currentUserId);
    final cartDoc = await cartRef.get();

    if (!cartDoc.exists) {
      await cartRef.set({
        'user_id': _currentUserId,
        'total_cost': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Add a product to cart
  Future<void> addProductToCart(Product product, int amount) async {
    if (_currentUserId == null) throw Exception('User not logged in');

    try {
      await _ensureCartExists();

      final cartRef = _firestore.collection('carts').doc(_currentUserId);
      final productRef = cartRef.collection('products').doc(product.id);
      final productDoc = await productRef.get();

      if (productDoc.exists) {
        await _updateExistingProduct(productRef, productDoc, amount);

        // Update local _items
        final index = _items.indexWhere((item) => item.productId == product.id);
        if (index >= 0) {
          _items[index].amount += amount;
        }
      } else {
        await _addNewProduct(cartRef, productRef, product, amount);

        // Add to local _items
        _items.add(CartItem(
          productId: product.id,
          product: product,
          amount: amount,
        ));
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

    await productRef.update({'amount': newAmount});
    await _updateCartMetadata();
  }

  Future<void> _addNewProduct(
    DocumentReference cartRef,
    DocumentReference productRef,
    Product product,
    int amount,
  ) async {
    await productRef.set({
      'product_id': product.id,
      'amount': amount,
    });
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

      // Remove from local _items
      _items.removeWhere((item) => item.productId == productId);

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

      // Update local _items
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index >= 0) {
        _items[index].amount = newAmount;
      }

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

  // Clear cart (both Firebase and local)
  Future<void> clearCart() async {
    if (_currentUserId == null) return;

    try {
      final cartRef = _firestore.collection('carts').doc(_currentUserId);
      final productsSnapshot = await cartRef.collection('products').get();

      final batch = _firestore.batch();
      for (var doc in productsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
    }
  }

  // Getters
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

  CartItem? getItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
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

  // Deprecated in-memory methods (kept for compatibility)
  @Deprecated('Use addProductToCart instead')
  void addItem(Product product, int quantity) {
    addProductToCart(product, quantity);
  }

  @Deprecated('Use removeProductFromCart instead')
  void removeItem(String cartItemId) {
    removeProductFromCart(cartItemId);
  }

  @Deprecated('Use updateProductAmount instead')
  void updateQuantity(String cartItemId, int newQuantity) {
    updateProductAmount(cartItemId, newQuantity);
  }

  @Deprecated('Use updateProductAmount instead')
  void incrementQuantity(String cartItemId) {
    final item = getItem(cartItemId);
    if (item != null) {
      updateProductAmount(cartItemId, item.amount + 1);
    }
  }

  @Deprecated('Use updateProductAmount instead')
  void decrementQuantity(String cartItemId) {
    final item = getItem(cartItemId);
    if (item != null) {
      updateProductAmount(cartItemId, item.amount - 1);
    }
  }

  @Deprecated('Use clearCart instead')
  void clear() {
    clearCart();
  }
}
