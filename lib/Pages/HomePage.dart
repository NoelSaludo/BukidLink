import 'package:bukidlink/services/CartService.dart';
import 'package:bukidlink/services/ProductService.dart';
import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/utils/PageNavigator.dart';
import 'package:bukidlink/pages/CartPage.dart';
import 'package:bukidlink/widgets/home/HomeAppBar.dart';
import 'package:bukidlink/widgets/common/SearchBarWidget.dart';
import 'package:bukidlink/widgets/home/CategoryGrid.dart';
import 'package:bukidlink/widgets/home/ProductGrid.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _handleRefresh() async {
    try {
      await Future.wait([
        ProductService().fetchProducts(),
        CartService().loadCart(),
      ]);
    } catch (e) {
      // ignore errors for refresh — UI will show errors via ProductGrid
    }
    setState(() {});
  }
  void _handleCartPressed() {
    PageNavigator().goToAndKeepWithTransition(
      context,
      const CartPage(),
      PageTransitionType.slideFromRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    CartService().loadCart();
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Column(
        children: [
          HomeAppBar(onCartPressed: _handleCartPressed),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.HEADER_GRADIENT_START,
                            AppColors.HEADER_GRADIENT_END,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [const SearchBarWidget(), const CategoryGrid()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'POPULAR PICKS',
                        style: AppTextStyles.sectionTitle,
                      ),
                    ),
                    ProductGrid(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
