class Product {
  final String id;
  final String name;
  final String farmName;
  final String priceInfo; // e.g., "Php 50 per kilo"
  final String imagePath;
  final String category;
  final double price; // Numeric price for sorting/filtering

  Product({
    required this.id,
    required this.name,
    required this.farmName,
    required this.priceInfo,
    required this.imagePath,
    required this.category,
    required this.price,
  });
}

