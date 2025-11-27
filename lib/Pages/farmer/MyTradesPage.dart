import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import '../../services/TradeService.dart';
import '../../models/TradeModels.dart';
import '../../widgets/common/ProductImage.dart';
import 'MakeTradePage.dart'; // Required for Edit Navigation

class MyTradesPage extends StatefulWidget {
  final bool embeddedInTab;

  MyTradesPage({this.embeddedInTab = false});

  @override
  _MyTradesPageState createState() => _MyTradesPageState();
}

class _MyTradesPageState extends State<MyTradesPage> {
  final TradeService _tradeService = TradeService();
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        // Search Bar (only when not embedded in a parent tab to avoid duplicates)
        if (!widget.embeddedInTab)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              decoration: InputDecoration(
                hintText: 'Search my items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // List of My Trades
        Expanded(
          child: StreamBuilder<List<TradeListing>>(
            stream: _tradeService.getMyTrades(searchText),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error loading data'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text("You haven't posted any trades yet."),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: List.generate(docs.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MyTradeItemCard(
                        listing: docs[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TradeIncomingOffersPage(
                                listing: docs[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.embeddedInTab) {
      return Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Trades', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: content,
    );
  }
}

// --- Widget: Card for "My Trades" (Shows Offer Count) ---
class MyTradeItemCard extends StatelessWidget {
  final TradeListing listing;
  final VoidCallback onTap;

  const MyTradeItemCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(
                  imagePath: listing.image.isNotEmpty ? listing.image : 'assets/images/default_cover_photo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${listing.quantity}\nPreferred: ${listing.preferredTrades.join(', ')}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Offer Badge
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFC3E956),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${listing.offersCount} Offers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Page: View Incoming Offers for a specific Listing + EDIT/DELETE ---
class TradeIncomingOffersPage extends StatelessWidget {
  final TradeListing listing;
  final TradeService _tradeService = TradeService();

  TradeIncomingOffersPage({required this.listing});

  // --- Helper: Delete Dialog ---
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Trade?"),
        content: Text(
          "Are you sure you want to delete this listing? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await _tradeService.deleteListing(listing.id);
              Navigator.pop(context); // Go back to My Trades list
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Trade deleted.")));
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.HEADER_GRADIENT_START,
                AppColors.HEADER_GRADIENT_END,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Trade Details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTextStyles.FONT_FAMILY,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MakeTradePage(listing: listing),
                  ),
                );
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Item Info (improved visual style)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with overlayed name/qty and offers badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ProductImage(
                            imagePath: listing.image.isNotEmpty ? listing.image : 'assets/images/default_cover_photo.png',
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // dark gradient at bottom for text contrast
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 70,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.45)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                          ),
                        ),
                        // Name and qty overlay (bottom-left)
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.name,
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Qty: ${listing.quantity}',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Offers badge (bottom-right)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Icon(Icons.local_offer, size: 14, color: Color(0xFF2F8A3E)),
                                SizedBox(width: 6),
                                Text('${listing.offersCount} Offers', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Product Details header with icon
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: Color(0xFFEFFBEF), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.info_outline, color: Color(0xFF2F8A3E), size: 20),
                        ),
                        SizedBox(width: 10),
                        Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Description box
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Text(listing.description, style: TextStyle(color: Colors.grey[800])),
                    ),
                    SizedBox(height: 16),
                    // Preferred Trades header with heart icon
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: Color(0xFFFFF9F0), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.favorite_border, color: Color(0xFF2F8A3E), size: 20),
                        ),
                        SizedBox(width: 10),
                        Text('Preferred Trades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: listing.preferredTrades.map((pref) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Color(0xFFF4F7EE), borderRadius: BorderRadius.circular(8)),
                          child: Text(pref, style: TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Received Offers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              // Offers List
              StreamBuilder<List<TradeOfferRequest>>(
                stream: _tradeService.getOffersForListing(listing.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text("Error loading offers");
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }

                  final offers = snapshot.data ?? [];

                  if (offers.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No offers received yet."),
                    );
                  }

                  return Column(
                    children: offers.map((offer) {
                      return _OfferTile(offer: offer);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final TradeOfferRequest offer;
  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    final offeredBy = (offer.offeredByName.trim().isEmpty) ? 'Anonymous' : offer.offeredByName;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFFF4F7EE),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ProductImage(
              imagePath: offer.imagePath.isNotEmpty ? offer.imagePath : 'assets/images/default_cover_photo.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.itemName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  'Quantity: ${offer.itemQuantity}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 6),
                Text(
                  'By: $offeredBy',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 96,
            height: 38,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Feature coming soon!")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBFEA6A),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text('Accept', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
