import 'package:flutter/material.dart';
import 'package:bukidlink/pages/StorePage.dart';
import 'package:bukidlink/data/ProductData.dart';
import 'package:bukidlink/utils/PageNavigator.dart';

/// Example usage demonstrations for the Store Page feature
/// 
/// This file contains various examples of how to navigate to and use
/// the Store Page in different scenarios.

class StorePageUsageExamples {
  // Example 1: Navigate to store from a button click
  static void navigateToStoreBasic(BuildContext context, String farmName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorePage(farmName: farmName),
      ),
    );
  }

  // Example 2: Navigate to store with custom transition
  static void navigateToStoreWithTransition(
    BuildContext context,
    String farmName,
  ) {
    PageNavigator().goToAndKeepWithTransition(
      context,
      StorePage(farmName: farmName),
      PageTransitionType.slideFromRight,
    );
  }

  // Example 3: Navigate to store with scale and fade transition
  static void navigateToStoreWithScaleFade(
    BuildContext context,
    String farmName,
  ) {
    PageNavigator().goToAndKeepWithTransition(
      context,
      StorePage(farmName: farmName),
      PageTransitionType.scaleAndFade,
    );
  }

  // Example 4: Check if farm has products before navigating
  static void navigateToStoreWithValidation(
    BuildContext context,
    String farmName,
  ) {
    final products = ProductData.getProductsByFarm(farmName);
    
    if (products.isEmpty) {
      // Show a message that the store has no products
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$farmName currently has no products'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      PageNavigator().goToAndKeepWithTransition(
        context,
        StorePage(farmName: farmName),
        PageTransitionType.slideFromRight,
      );
    }
  }

  // Example 5: Build a list of all stores and navigate to selected one
  static Widget buildStoreListExample(BuildContext context) {
    final allFarms = ProductData.getAllFarmNames();

    return ListView.builder(
      itemCount: allFarms.length,
      itemBuilder: (context, index) {
        final farmName = allFarms[index];
        final productCount = ProductData.getProductsByFarm(farmName).length;

        return ListTile(
          leading: const Icon(Icons.store),
          title: Text(farmName),
          subtitle: Text('$productCount products'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => navigateToStoreWithTransition(context, farmName),
        );
      },
    );
  }

  // Example 6: Build a grid of store cards
  static Widget buildStoreGridExample(BuildContext context) {
    final allFarms = ProductData.getAllFarmNames();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: allFarms.length,
      itemBuilder: (context, index) {
        final farmName = allFarms[index];
        final products = ProductData.getProductsByFarm(farmName);

        return GestureDetector(
          onTap: () => navigateToStoreWithTransition(context, farmName),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    farmName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${products.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Example 7: Navigate from product details "Sold by" section
  static void navigateFromProductDetails(
    BuildContext context,
    String farmName,
  ) {
    // This is automatically handled in ProductDetailsCard.dart
    // But you can also call it manually:
    PageNavigator().goToAndKeepWithTransition(
      context,
      StorePage(farmName: farmName),
      PageTransitionType.slideFromRight,
    );
  }

  // Example 8: Get store statistics before navigation
  static Map<String, dynamic> getStoreStats(String farmName) {
    final products = ProductData.getProductsByFarm(farmName);
    final categories = products.map((p) => p.category).toSet();
    
    final totalRating = products
        .where((p) => p.rating != null)
        .map((p) => p.rating!)
        .fold(0.0, (a, b) => a + b);
    
    final avgRating = products.isNotEmpty 
        ? totalRating / products.where((p) => p.rating != null).length
        : 0.0;

    return {
      'farmName': farmName,
      'totalProducts': products.length,
      'categories': categories.length,
      'averageRating': avgRating,
      'hasProducts': products.isNotEmpty,
    };
  }

  // Example 9: Build a search interface for stores
  static Widget buildStoreSearchExample(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            controller.openView();
          },
          leading: const Icon(Icons.search),
          hintText: 'Search stores...',
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final allFarms = ProductData.getAllFarmNames();
        final filteredFarms = allFarms
            .where((farm) =>
                farm.toLowerCase().contains(controller.text.toLowerCase()))
            .toList();

        return filteredFarms.map((farm) {
          final productCount = ProductData.getProductsByFarm(farm).length;
          return ListTile(
            leading: const Icon(Icons.store),
            title: Text(farm),
            subtitle: Text('$productCount products'),
            onTap: () {
              controller.closeView(farm);
              navigateToStoreWithTransition(context, farm);
            },
          );
        });
      },
    );
  }

  // Example 10: Navigate to store and pre-select a category
  // Note: This would require updating StorePage to accept an optional category parameter
  static void navigateToStoreWithCategory(
    BuildContext context,
    String farmName,
    String? initialCategory,
  ) {
    // For now, just navigate to the store
    // Future enhancement: Add initialCategory parameter to StorePage
    PageNavigator().goToAndKeepWithTransition(
      context,
      StorePage(farmName: farmName),
      PageTransitionType.slideFromRight,
    );
    
    // TODO: Add category selection after navigation
  }
}

// Example Widget: Store Directory Page
class StoreDirectoryExample extends StatelessWidget {
  const StoreDirectoryExample({super.key});

  @override
  Widget build(BuildContext context) {
    final allFarms = ProductData.getAllFarmNames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Stores'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: StorePageUsageExamples.buildStoreSearchExample(context),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allFarms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final farmName = allFarms[index];
                final stats = StorePageUsageExamples.getStoreStats(farmName);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5C8D43), Color(0xFF9BCF6F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      farmName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2, size: 14),
                          const SizedBox(width: 4),
                          Text('${stats['totalProducts']} products'),
                          const SizedBox(width: 16),
                          const Icon(Icons.category, size: 14),
                          const SizedBox(width: 4),
                          Text('${stats['categories']} categories'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      StorePageUsageExamples.navigateToStoreWithTransition(
                        context,
                        farmName,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
