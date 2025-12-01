import 'package:bukidlink/models/Product.dart';

class ProductData {
  static final List<Product> _allProducts = [
    // Fruits
    Product(
      id: '1',
      name: 'Apple',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/apple.png',
      category: 'Fruits',
      price: 50,
      description:
      'Crisp and sweet apples, freshly harvested from our organic orchards. Perfect for snacking or baking.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 24,
      availability: 'In Stock',
      stockCount: 150,
    ),
    Product(
      id: '2',
      name: 'Mango',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/mango.png',
      category: 'Fruits',
      price: 50,
      description:
      'Juicy and sweet Philippine mangoes, hand-picked at peak ripeness for maximum flavor.',
      rating: 4.8,
      unit: 'kg',
      reviewCount: 42,
      availability: 'In Stock',
      stockCount: 200,
    ),
    Product(
      id: '3',
      name: 'Strawberry',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/strawberry.png',
      category: 'Fruits',
      price: 300,
      description:
      'Premium fresh strawberries grown in our highland farms. Sweet, juicy and perfect for desserts.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 18,
      availability: 'Out of Stock',
      stockCount: 0,
    ),
    Product(
      id: '4',
      name: 'Grapes',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/grapes.png',
      category: 'Fruits',
      price: 70,
      description:
      'Sweet and seedless grapes, carefully grown and harvested. Great for healthy snacking.',
      rating: 4.6,
      unit: 'kg',
      availability: 'In Stock',
      stockCount: 120,
    ),
    Product(
      id: '5',
      name: 'Pineapple',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/pineapple.png',
      category: 'Fruits',
      price: 167,
      description:
      'Fresh tropical pineapples with a perfect balance of sweetness and tang. Excellent for fresh juice.',
      rating: 4.4,
      unit: 'kg',
      availability: 'In Stock',
      stockCount: 80,
    ),
    Product(
      id: '6',
      name: 'Banana',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/banana.png',
      category: 'Fruits',
      price: 40,
      description:
      'Locally grown bananas, rich in nutrients and perfect for energy. Ideal for smoothies or snacking.',
      rating: 4.3,
      unit: 'kg',
      availability: 'In Stock',
      stockCount: 250,
    ),

    // Vegetables
    Product(
      id: '7',
      name: 'Carrots',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/carrots.png',
      category: 'Vegetables',
      price: 50,
      description:
      'Fresh and crunchy carrots, rich in vitamins and beta-carotene. Perfect for salads, stir-fries, or healthy snacking.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 31,
      availability: 'In Stock',
      stockCount: 180,
    ),
    Product(
      id: '8',
      name: 'Eggplant',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/eggplant.png',
      category: 'Vegetables',
      price: 50,
      description:
      'Locally grown eggplants with smooth, glossy skin. Ideal for grilling, baking, or traditional Filipino dishes.',
      rating: 4.4,
      unit: 'kg',
      reviewCount: 27,
      availability: 'In Stock',
      stockCount: 160,
    ),
    Product(
      id: '9',
      name: 'Broccoli',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/broccoli.png',
      category: 'Vegetables',
      price: 300,
      description:
      'Premium fresh broccoli florets, packed with nutrients and fiber. Great for steaming, stir-frying, or salads.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 15,
      availability: 'Out of Stock',
      stockCount: 0,
    ),
    Product(
      id: '10',
      name: 'Potato',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/potato.png',
      category: 'Vegetables',
      price: 70,
      description:
      'Quality potatoes perfect for mashing, frying, or roasting. Versatile and essential for any kitchen.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 38,
      availability: 'In Stock',
      stockCount: 300,
    ),
    Product(
      id: '11',
      name: 'Spinach',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/spinach.png',
      category: 'Vegetables',
      price: 167,
      description:
      'Fresh spinach leaves loaded with iron and vitamins. Excellent for salads, smoothies, or sautéed dishes.',
      rating: 4.3,
      unit: 'kg',
      reviewCount: 22,
      availability: 'In Stock',
      stockCount: 140,
    ),
    Product(
      id: '12',
      name: 'Yardlong Bean',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/yardlong_bean.png',
      category: 'Vegetables',
      price: 40,
      description:
      'Fresh yardlong beans (sitaw), crisp and tender. Perfect for pinakbet, adobo, or stir-fried vegetables.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 29,
      availability: 'In Stock',
      stockCount: 220,
    ),

    // Grains
    Product(
      id: '13',
      name: 'Sinandomeng',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/sinandomeng.png',
      category: 'Grains',
      price: 50,
      description:
      'Premium Sinandomeng rice, known for its soft texture and aromatic fragrance.',
      rating: 4.8,
      unit: 'kg',
      reviewCount: 56,
      availability: 'In Stock',
      stockCount: 500,
    ),
    Product(
      id: '14',
      name: 'Jasmine Rice',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/jasmine_rice.png',
      category: 'Grains',
      price: 50,
      description:
      'Fragrant jasmine rice with a delicate floral aroma. Fluffy and slightly sticky when cooked.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 44,
      availability: 'In Stock',
      stockCount: 450,
    ),
    Product(
      id: '15',
      name: 'Malagkit',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/malagkit.png',
      category: 'Grains',
      price: 300,
      description:
      'Authentic glutinous rice perfect for Filipino desserts like suman, biko, and bibingka.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 33,
      availability: 'In Stock',
      stockCount: 180,
    ),
    Product(
      id: '16',
      name: 'Dinorado',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/dinorado.png',
      category: 'Grains',
      price: 70,
      description:
      'Premium Dinorado rice with a nutty flavor and firm texture.',
      rating: 4.9,
      unit: 'kg',
      reviewCount: 62,
      availability: 'In Stock',
      stockCount: 350,
    ),
    Product(
      id: '17',
      name: 'Barley',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/barley.png',
      category: 'Grains',
      price: 167,
      description:
      'Nutritious barley, rich in fiber and minerals. Great for soups or salads.',
      rating: 4.4,
      unit: 'kg',
      reviewCount: 19,
      availability: 'In Stock',
      stockCount: 95,
    ),
    Product(
      id: '18',
      name: 'Oats',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/oats.png',
      category: 'Grains',
      price: 40,
      description:
      'Whole grain oats ideal for porridge, baking, or smoothies.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 37,
      availability: 'In Stock',
      stockCount: 280,
    ),

    // Livestock
    Product(
      id: '19',
      name: 'Beef',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/beef.png',
      category: 'Livestock',
      price: 50,
      description:
      'Premium beef from grass-fed cattle. Tender and flavorful.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 41,
      availability: 'In Stock',
      stockCount: 110,
    ),
    Product(
      id: '20',
      name: 'Chicken Whole',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/chicken.png',
      category: 'Livestock',
      price: 50,
      description:
      'Fresh whole chicken from free-range farms.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 52,
      availability: 'In Stock',
      stockCount: 150,
    ),
    Product(
      id: '21',
      name: 'Pork',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/pork.png',
      category: 'Livestock',
      price: 300,
      description:
      'Fresh pork cuts from locally raised pigs.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 48,
      availability: 'In Stock',
      stockCount: 90,
    ),
    Product(
      id: '22',
      name: 'Eggs',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/eggs.png',
      category: 'Livestock',
      price: 70,
      description:
      'Farm-fresh eggs from free-range chickens.',
      rating: 4.8,
      unit: 'kg',
      reviewCount: 67,
      availability: 'In Stock',
      stockCount: 400,
    ),
    Product(
      id: '23',
      name: 'Rabbit Meat',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/rabbit.png',
      category: 'Livestock',
      price: 167,
      description:
      'Lean and tender rabbit meat.',
      rating: 4.3,
      unit: 'kg',
      reviewCount: 14,
      availability: 'Out of Stock',
      stockCount: 0,
    ),
    Product(
      id: '24',
      name: 'Ham',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/ham.png',
      category: 'Livestock',
      price: 40,
      description:
      'Cured and smoked ham with rich flavor.',
      rating: 4.4,
      unit: 'kg',
      reviewCount: 25,
      availability: 'In Stock',
      stockCount: 75,
    ),

    // Dairy
    Product(
      id: '25',
      name: 'Parmesan',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/parmesan.png',
      category: 'Dairy',
      price: 50,
      description: 'Aged Parmesan cheese.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 35,
      availability: 'In Stock',
      stockCount: 60,
    ),
    Product(
      id: '26',
      name: 'Butter',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/butter.png',
      category: 'Dairy',
      price: 50,
      description: 'Creamy farm-fresh butter.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 58,
      availability: 'In Stock',
      stockCount: 180,
    ),
    Product(
      id: '27',
      name: 'Sour Cream',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/sour_cream.png',
      category: 'Dairy',
      price: 300,
      description: 'Thick and tangy sour cream.',
      rating: 4.4,
      unit: 'kg',
      reviewCount: 21,
      availability: 'In Stock',
      stockCount: 45,
    ),
    Product(
      id: '28',
      name: 'Fresh Milk',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/fresh_milk.png',
      category: 'Dairy',
      price: 70,
      description: 'Pure and fresh milk.',
      rating: 4.8,
      unit: 'kg',
      reviewCount: 73,
      availability: 'In Stock',
      stockCount: 250,
    ),
    Product(
      id: '29',
      name: 'Cream Cheese',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/cream_cheese.png',
      category: 'Dairy',
      price: 167,
      description: 'Smooth and creamy cheese spread.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 28,
      availability: 'In Stock',
      stockCount: 70,
    ),
    Product(
      id: '30',
      name: 'Mozzarella',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/mozzarella.png',
      category: 'Dairy',
      price: 40,
      description: 'Fresh mozzarella cheese.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 46,
      availability: 'In Stock',
      stockCount: 130,
    ),

    // Others
    Product(
      id: '31',
      name: 'Lagundi',
      farmerId: '2',
      farmName: 'De Castro Farms',
      imagePath: 'assets/images/lagundi.png',
      category: 'Others',
      price: 50,
      description:
      'Organic lagundi leaves, known for health benefits.',
      rating: 4.5,
      unit: 'kg',
      reviewCount: 23,
      availability: 'In Stock',
      stockCount: 55,
    ),
    Product(
      id: '32',
      name: 'Roses',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/roses.png',
      category: 'Others',
      price: 50,
      description: 'Fresh-cut roses.',
      rating: 4.7,
      unit: 'kg',
      reviewCount: 39,
      availability: 'In Stock',
      stockCount: 100,
    ),
    Product(
      id: '33',
      name: 'Mint',
      farmerId: '1',
      farmName: 'Farmjuseyo',
      imagePath: 'assets/images/mint.png',
      category: 'Others',
      price: 300,
      description: 'Fresh aromatic mint leaves.',
      rating: 4.6,
      unit: 'kg',
      reviewCount: 17,
      availability: 'In Stock',
      stockCount: 40,
    ),
    Product(
      id: '34',
      name: 'Wool',
      farmerId: '3',
      farmName: 'Farm Lourdes',
      imagePath: 'assets/images/wool.png',
      category: 'Others',
      price: 70,
      description: 'Premium sheep wool.',
      rating: 4.4,
      unit: 'kg',
      reviewCount: 12,
      availability: 'Limited',
      stockCount: 15,
    ),
    Product(
      id: '35',
      name: 'Feathers',
      farmerId: '4',
      farmName: 'Fernandez Domingo',
      imagePath: 'assets/images/feathers.png',
      category: 'Others',
      price: 167,
      description: 'Clean poultry feathers.',
      rating: 4.2,
      unit: 'kg',
      reviewCount: 8,
      availability: 'Limited',
      stockCount: 12,
    ),
    Product(
      id: '36',
      name: 'Beeswax',
      farmerId: '5',
      farmName: 'Tindahan ni Evelin',
      imagePath: 'assets/images/beeswax.png',
      category: 'Others',
      price: 40,
      description: 'Pure natural beeswax.',
      rating: 4.8,
      unit: 'kg',
      reviewCount: 34,
      availability: 'In Stock',
      stockCount: 85,
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

  // Get popular products
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

  // Get products by farm name
  static List<Product> getProductsByFarm(String farmName) {
    return _allProducts.where((p) => p.farmName == farmName).toList();
  }

  // Get all unique farm names
  static List<String> getAllFarmNames() {
    final farmNames = <String>{};
    for (var product in _allProducts) {
      farmNames.add(product.farmName);
    }
    return farmNames.toList()..sort();
  }
}
