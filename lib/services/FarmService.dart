import 'package:bukidlink/models/Farm.dart';
import 'package:bukidlink/models/Product.dart';
import 'package:bukidlink/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final FarmService _instance = FarmService._internal();
  factory FarmService() {
    return _instance;
  }
  FarmService._internal();

  // Fetch products associated with a specific farm
  Future<List<Product>> fetchProductsByFarm(String farmId) async {
    List<Product> products = [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('farm_id', isEqualTo: farmId)
          .get();

      for (var doc in snapshot.docs) {
        final product = Product.fromDocument(doc);
        if (product.isVisible) {
          products.add(product);
        }
      }
    } catch (e) {
      print('Error fetching products by farm: $e');
    }

    return products;
  }

  // Add a new product to the farm (and global products collection)
  Future<void> addProductToFarm(Product product) async {
    try {
      final CollectionReference productsColl = _firestore.collection('products');

      DocumentReference docRef;
      if (product.id.isNotEmpty) {
        docRef = productsColl.doc(product.id);
        await docRef.set(product.toJson());
      } else {
        docRef = productsColl.doc();
        final json = product.toJson();
        json['id'] = docRef.id;
        await docRef.set(json);
      }
    } catch (e) {
      debugPrint('Error adding product to farm: $e');
      rethrow;
    }
  }

  // Soft delete (archive) a product
  Future<void> archiveProduct(String productId) async {
    if (productId.isEmpty) return;
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'isVisible': false});
    } catch (e) {
      debugPrint('Error archiving product: $e');
      rethrow;
    }
  }

  // Fetch a Farm document given its DocumentReference
  Future<Farm?> getFarmByReference(DocumentReference? farmRef) async {
    if (farmRef == null) {
      debugPrint('getFarmByReference called with null farmRef');
      return null;
    }
    try {
      final doc = await farmRef.get();
      if (!doc.exists) {
        debugPrint('No farm found for reference: ${farmRef.path}');
        return null;
      }
        return Farm.fromDocument(doc);
    } catch (e) {
      print('Error fetching farm by reference: $e');
      return null;
    }
  }

  // Convenience: fetch the farm for a given User model
  Future<Farm?> getFarmForUser(User? user) async {
    if (user == null) return null;
    return await getFarmByReference(user.farmId);
  }
}
