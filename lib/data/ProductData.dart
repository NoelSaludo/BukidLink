import 'package:bukidlink/models/Product.dart';

class ProductData {
  static final List<Product> _allProducts = [
    // Fruits
    Product(
      id: '1',
      name: 'Apple',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/apple.png',
      category: 'Fruits',
      price: 50,
    ),
    Product(
      id: '2',
      name: 'Mango',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/mango.png',
      category: 'Fruits',
      price: 50,
    ),
    Product(
      id: '3',
      name: 'Strawberry',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/strawberry.png',
      category: 'Fruits',
      price: 300,
    ),
    Product(
      id: '4',
      name: 'Grapes',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/grapes.png',
      category: 'Fruits',
      price: 70,
    ),
    Product(
      id: '5',
      name: 'Pineapple',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/pineapple.png',
      category: 'Fruits',
      price: 167,
    ),
    Product(
      id: '6',
      name: 'Banana',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/banana.png',
      category: 'Fruits',
      price: 40,
    ),

    // Vegetables
    Product(
      id: '7',
      name: 'Carrots',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/carrots.png',
      category: 'Vegetables',
      price: 50,
    ),
    Product(
      id: '8',
      name: 'Eggplant',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/eggplant.png',
      category: 'Vegetables',
      price: 50,
    ),
    Product(
      id: '9',
      name: 'Broccoli',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/broccoli.png',
      category: 'Vegetables',
      price: 300,
    ),
    Product(
      id: '10',
      name: 'Potato',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/potato.png',
      category: 'Vegetables',
      price: 70,
    ),
    Product(
      id: '11',
      name: 'Spinach',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/spinach.png',
      category: 'Vegetables',
      price: 167,
    ),
    Product(
      id: '12',
      name: 'Yardlong Bean',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/yardlong_bean.png',
      category: 'Vegetables',
      price: 40,
    ),

    // Grains
    Product(
      id: '13',
      name: 'Sinandomeng',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/sinandomeng.png',
      category: 'Grains',
      price: 50,
    ),
    Product(
      id: '14',
      name: 'Jasmine Rice',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/jasmine_rice.png',
      category: 'Grains',
      price: 50,
    ),
    Product(
      id: '15',
      name: 'Malagkit',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/malagkit.png',
      category: 'Grains',
      price: 300,
    ),
    Product(
      id: '16',
      name: 'Dinorado',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/dinorado.png',
      category: 'Grains',
      price: 70,
    ),
    Product(
      id: '17',
      name: 'Barley',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/barley.png',
      category: 'Grains',
      price: 167,
    ),
    Product(
      id: '18',
      name: 'Oats',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/oats.png',
      category: 'Grains',
      price: 40,
    ),

    // Livestock
    Product(
      id: '19',
      name: 'Beef',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/beef.png',
      category: 'Livestock',
      price: 50,
    ),
    Product(
      id: '20',
      name: 'Chicken Whole',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/chicken.png',
      category: 'Livestock',
      price: 50,
    ),
    Product(
      id: '21',
      name: 'Pork',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/pork.png',
      category: 'Livestock',
      price: 300,
    ),
    Product(
      id: '22',
      name: 'Eggs',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/eggs.png',
      category: 'Livestock',
      price: 70,
    ),
    Product(
      id: '23',
      name: 'Rabbit Meat',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/rabbit.png',
      category: 'Livestock',
      price: 167,
    ),
    Product(
      id: '24',
      name: 'Ham',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/ham.png',
      category: 'Livestock',
      price: 40,
    ),

    // Dairy
    Product(
      id: '25',
      name: 'Parmesan',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/parmesan.png',
      category: 'Dairy',
      price: 50,
    ),
    Product(
      id: '26',
      name: 'Butter',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/butter.png',
      category: 'Dairy',
      price: 50,
    ),
    Product(
      id: '27',
      name: 'Sour Cream',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/sour_cream.png',
      category: 'Dairy',
      price: 300,
    ),
    Product(
      id: '28',
      name: 'Fresh Milk',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/fresh_milk.png',
      category: 'Dairy',
      price: 70,
    ),
    Product(
      id: '29',
      name: 'Cream Cheese',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/cream_cheese.png',
      category: 'Dairy',
      price: 167,
    ),
    Product(
      id: '30',
      name: 'Mozzarella',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/mozzarella.png',
      category: 'Dairy',
      price: 40,
    ),

    // Others
    Product(
      id: '31',
      name: 'Lagundi',
      farmName: 'De Castro Farms',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/lagundi.png',
      category: 'Others',
      price: 50,
    ),
    Product(
      id: '32',
      name: 'Roses',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 50 per kilo',
      imagePath: 'assets/images/roses.png',
      category: 'Others',
      price: 50,
    ),
    Product(
      id: '33',
      name: 'Mint',
      farmName: 'Farmjuseyo',
      priceInfo: 'Php 300 per kilo',
      imagePath: 'assets/images/mint.png',
      category: 'Others',
      price: 300,
    ),
    Product(
      id: '34',
      name: 'Wool',
      farmName: 'Farm Lourdes',
      priceInfo: 'Php 70 per kilo',
      imagePath: 'assets/images/wool.png',
      category: 'Others',
      price: 70,
    ),
    Product(
      id: '35',
      name: 'Feathers',
      farmName: 'Fernandez Domingo',
      priceInfo: 'Php 167 per kilo',
      imagePath: 'assets/images/feathers.png',
      category: 'Others',
      price: 167,
    ),
    Product(
      id: '36',
      name: 'Beeswax',
      farmName: 'Tindahan ni Evelin',
      priceInfo: 'Php 40 per kilo',
      imagePath: 'assets/images/beeswax.png',
      category: 'Others',
      price: 40,
    ),
  ];

  // Get all products
  static List<Product> getAllProducts() {
    return _allProducts;
  }

  // Get products by category
  static List<Product> getProductsByCategory(String category) {
    if (category == 'More') {
      return _allProducts.where((p) => p.category == 'Others').toList();
    }
    return _allProducts.where((p) => p.category == category).toList();
  }

  // Get popular products (for homepage)
  static List<Product> getPopularProducts({int limit = 6}) {
    return _allProducts.take(limit).toList();
  }

  // Search products
  static List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(lowercaseQuery) ||
          p.farmName.toLowerCase().contains(lowercaseQuery) ||
          p.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get product by ID
  static Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
