import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/services/ApiClient.dart';
import 'package:bukidlink/models/ProductReview.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiClient _api = ApiClient();

  final List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // get all products from backend
  Future<void> fetchAllProducts() async {
    _setLoading(true);
    try {
      final response = await _api.get('/api/products');
      final data = response.data;

      if (data is List) {
        _products
          ..clear()
          ..addAll(data.map((json) => _fromJson(json)).toList());
      }

      _errorMessage = null;
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // get single product by ID
  Future<Product?> fetchProductById(String id) async {
    _setLoading(true);
    try {
      final response = await _api.get('/api/products/$id');
      _errorMessage = null;
      return _fromJson(response.data);
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// add new product
  Future<bool> addProduct(Product product) async {
    try {
      final response = await _api.post('/api/products', data: _toJson(product));
      final newProduct = _fromJson(response.data);
      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  /// update existing product
  Future<bool> updateProduct(String id, Product product) async {
    try {
      await _api.put('/api/products/$id', data: _toJson(product));

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = product;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  /// delete product by ID
  Future<bool> deleteProduct(String id) async {
    try {
      await _api.delete('/api/products/$id');
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // helpers

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      _errorMessage = error.message;
      debugPrint('API Error: ${error.message}');
    } else {
      _errorMessage = 'Unexpected error: $error';
      debugPrint('Unexpected error: $error');
    }
    notifyListeners();
  }

  // JSON to Product
  // This involves the product reviews, not sure if it should be separated?

  Product _fromJson(dynamic json) {
    List<ProductReview>? reviews;
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = (json['reviews'] as List)
          .map(
            (r) => ProductReview(
              id: r['id'].toString(),
              userName: r['userName'] ?? '',
              userAvatar: r['userAvatar'] ?? '',
              rating: (r['rating'] ?? 0).toDouble(),
              comment: r['comment'] ?? '',
              date: r['date'] ?? '',
              isVerifiedPurchase: r['isVerifiedPurchase'] ?? false,
            ),
          )
          .toList();
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      farmName: json['farmName'] ?? '',
      imagePath: json['imagePath'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      availability: json['availability'] ?? 'In Stock',
      stockCount: json['stockCount'] ?? 0,
      description: json['description'],
      rating: (json['rating'] ?? 0).toDouble(),
      unit: json['unit'],
      reviewCount: json['reviewCount'],
      reviews: reviews,
    );
  }
}

// Product to JSON
Map<String, dynamic> _toJson(Product product, {bool includeId = false}) {
  final data = {
    'name': product.name,
    'farmName': product.farmName,
    'imagePath': product.imagePath,
    'category': product.category,
    'price': product.price,
    'availability': product.availability,
    'stockCount': product.stockCount,
    'description': product.description,
    'rating': product.rating,
    'unit': product.unit,
    'reviewCount': product.reviewCount,
  };

  if (includeId) {
    data['id'] = product.id;
  }

  return data;
}
