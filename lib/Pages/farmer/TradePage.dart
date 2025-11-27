import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/TradeWidgets.dart';
import 'package:bukidlink/services/TradeService.dart';
import 'package:bukidlink/models/TradeModels.dart';
import 'MakeTradePage.dart';
import 'OfferTradePage.dart';
import 'MyTradesPage.dart';

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> with TickerProviderStateMixin {
  final TradeService _tradeService = TradeService();
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  late TabController _tabController;
  int _tabCount = 2;

  @override
  void initState() {
    super.initState();
    _initTabController(_tabCount);
  }

  void _initTabController(int length) {
    // Dispose existing controller if present
    try {
      _tabController.dispose();
    } catch (_) {}

    _tabController = TabController(length: length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant TradePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure controller length matches current tab count (helps on hot-reload)
    if (_tabController.length != _tabCount) {
      final currentIndex = _tabController.index.clamp(0, _tabCount - 1);
      _initTabController(_tabCount);
      _tabController.index = currentIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width > 900 ? 3 : width > 600 ? 2 : 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      body: Column(
        children: [
          const FarmerAppBar(),

          // Header with gradient and tabs
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
              children: [
                // Search + actions placed inside header to match store layout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) => setState(() => searchText = value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search trades, products...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              suffixIcon: searchText.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white),
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() => searchText = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      // removed: quick MyTrades button to simplify header
                    ],
                  ),
                ),

                // Tab bar: make non-scrollable so tabs evenly distribute
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    // Reduce horizontal padding and increase vertical padding so the pill is larger/taller
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    // larger label padding gives the content breathing room and matches pill size
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.DARK_TEXT,
                    unselectedLabelColor: Colors.white,
                    labelStyle: AppTextStyles.FARMER_TAB_LABEL,
                    unselectedLabelStyle: AppTextStyles.FARMER_TAB_LABEL_UNSELECTED,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Trades'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 20),
                            SizedBox(width: 8),
                            Text('My Trades'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Make a trade button styled like Sell button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MakeTradePage()));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.ACCENT_LIME,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Make a trade',
                          style: AppTextStyles.SELL_PRODUCT_BUTTON,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradesList(width, crossAxis),
                MyTradesPage(embeddedInTab: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTradesList(double width, int crossAxis) {
    return _buildListingsStream(width, crossAxis);
  }

  Widget _buildListingsStream(double width, int crossAxis) {
    return StreamBuilder<List<TradeListing>>(
      stream: _tradeService.getTradeListings(searchText),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error loading trades'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        final listings = snapshot.data ?? [];

        if (listings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_horiz, size: 64, color: AppColors.TEXT_SECONDARY.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text('No trades found', style: TextStyle(fontSize: 18, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text('Create your first trade or check back later.', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  // duplicate make-trade button removed (primary CTA available above)
                ],
              ),
            ),
          );
        }

        // Ensure cards have enough height to fit content on mobile (avoid overflow)
        // Increase target height for single-column layout to prevent bottom overflow.
        final double childAspectRatio =
          crossAxis == 1 ? (width / 240.0) : (width > 600 ? 0.8 : 0.9);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final item = listings[index];
            return TradeListingCard(
              listing: item,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferTradePage(listing: item))),
            );
          },
        );
      },
    );
  }
}
