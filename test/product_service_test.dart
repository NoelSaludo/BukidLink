import 'package:flutter_test/flutter_test.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:bukidlink/models/Product.dart';

void main() {
  final productService = ProductService();

  group('ProductService Tests', () {
    test('Fetch all products', () async {
      await productService.fetchAllProducts();

      expect(productService.errorMessage, isNull);
      expect(productService.products, isA<List<Product>>());

      print('Products fetched: ${productService.products.length}');
    });

    test('Fetch single product by ID', () async {
      // mock testing
      const testId = '1';

      final product = await productService.fetchProductById(testId);

      if (product != null) {
        print('Product fetched: ${product.name}');
        expect(product.id, testId);
      } else {
        print('No product found for ID $testId');
      }
    });

    test('Add a new product', () async {
      final newProduct = Product(
        id: '1909', // just for testing
        name: 'Test Product',
        farmName: 'Test Farm',
        imagePath: 'images/test.jpg',
        category: 'Vegetables',
        price: 120.0,
        availability: 'In Stock',
        stockCount: 50,
      );

      final success = await productService.addProduct(newProduct);
      expect(success, true);

      print('Product added successfully');
    });

    test('Update a product', () async {
      const productId = '1';
      final updated = Product(
        id: productId,
        name: 'Updated Product',
        farmName: 'Updated Farm',
        imagePath: 'images/updated.jpg',
        category: 'Fruits',
        price: 150.0,
        availability: 'Limited',
        stockCount: 10,
      );

      final success = await productService.updateProduct(productId, updated);
      expect(success, true);

      print('Product updated successfully');
    });

    test('Delete a product', () async {
      const productId = '1';
      final success = await productService.deleteProduct(productId);
      expect(success, true);

      print('Product deleted successfully');
    });
  });
}
