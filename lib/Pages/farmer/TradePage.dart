import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';

// Trade Page Main
class TradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const FarmerAppBar(),

          // Search Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Cards
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MakeTradePage(),
                                ),
                              );
                            },
                            child: TradeCard(
                              title: 'Make a Trade',
                              icon: Icons.add_shopping_cart,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyTradesPage(),
                                ),
                              );
                            },
                            child: TradeCard(
                              title: 'My Trades',
                              icon: Icons.list_alt,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Mock Trade Items
                    Row(
                      children: [
                        Expanded(
                          child: TradeItemCard(
                            name: 'Tomato',
                            image: 'assets/images/tomato.png',
                            quantity: '3 kg',
                            preferred: 'Grapes',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TradeItemCard(
                            name: 'Mango',
                            image: 'assets/images/mango.png',
                            quantity: '5 kg',
                            preferred: 'Apples',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TradeItemCard(
                            name: 'Grapes',
                            image: 'assets/images/grapes.png',
                            quantity: '3 kg',
                            preferred: 'Onions',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TradeItemCard(
                            name: 'Tomato',
                            image: 'assets/images/tomato.png',
                            quantity: '3 kg',
                            preferred: 'Grapes',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 1),
    );
  }
}

// Card Widgets
class TradeCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const TradeCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//trade item cards for mock trade
class TradeItemCard extends StatelessWidget {
  final String name;
  final String image;
  final String quantity;
  final String preferred;

  const TradeItemCard({
    required this.name,
    required this.image,
    required this.quantity,
    required this.preferred,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OfferTradePage(name: name, image: image, quantity: quantity),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          width: 167,
          height: 230,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),

              // Name
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 4),

              // Quantity & Preferred
              Text(
                '$quantity, Preferred: $preferred',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),

              Spacer(),

              // Offer a Trade Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Offer a Trade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3E956),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Offer a Trade Page Mock Page for now, extension from Trade Page Main

class OfferTradePage extends StatelessWidget {
  final String name;
  final String image;
  final String quantity;

  OfferTradePage({
    required this.name,
    required this.image,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Top AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Offer a Trade", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gradient Box + Image
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F4A2C), Color(0xFFC3E956)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [Image.asset(image, height: 140)]),
              ),

              SizedBox(height: 16),

              // Category
              Text(
                "Fruit",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              SizedBox(height: 4),

              // Name
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 4),

              // Quantity
              Text(quantity, style: TextStyle(fontSize: 16)),

              SizedBox(height: 20),

              // Product Details
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Picked at the peak of ripeness, our fresh red tomatoes bring natural sweetness. "
                  "Bursting with juice, they're perfect for salad.",
                  style: TextStyle(fontSize: 15),
                ),
              ),

              SizedBox(height: 20),

              // Preferred Trades
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preferred Trades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 6),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Grapes"),
                    Text("• Apples"),
                    Text("• Sitaw"),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Offer a Trade Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Offer a Trade", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3E956),
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

//Make Trade Page
class MakeTradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Make a Trade', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Item Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text('Add Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Preferred Trades',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add preferred trade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(50, 50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Post Trade Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3E956),
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// My Trades Page
class MyTradesPage extends StatelessWidget {
  // Mock trade data for now
  final List<Map<String, dynamic>> trades = [
    {
      'name': 'Tomato',
      'image': 'assets/images/tomato.png',
      'quantity': '3 kg',
      'preferred': 'Grapes',
      'offers': 5,
    },
    {
      'name': 'Mango',
      'image': 'assets/images/mango.png',
      'quantity': '5 kg',
      'preferred': 'Apples',
      'offers': 3,
    },
    {
      'name': 'Grapes',
      'image': 'assets/images/grapes.png',
      'quantity': '3 kg',
      'preferred': 'Onions',
      'offers': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Scrollable cards
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: List.generate((trades.length / 2).ceil(), (
                    rowIndex,
                  ) {
                    final int firstIndex = rowIndex * 2;
                    final int secondIndex = firstIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          // First card
                          if (firstIndex < trades.length)
                            Expanded(
                              child: MyTradeCard(trade: trades[firstIndex]),
                            ),
                          SizedBox(width: 12),
                          // Second card
                          if (secondIndex < trades.length)
                            Expanded(
                              child: MyTradeCard(trade: trades[secondIndex]),
                            )
                          else
                            Expanded(child: Container()), // Empty space
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card for My Trades
class MyTradeCard extends StatelessWidget {
  final Map<String, dynamic> trade;

  const MyTradeCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TradeOfferPage(trade: trade)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(trade['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                trade['name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '${trade['quantity']}, Preferred: ${trade['preferred']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFC3E956),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${trade['offers']} Offers',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Trade Offer Owner extension from My Trades Page

class TradeOfferPage extends StatelessWidget {
  final Map<String, dynamic> trade;

  TradeOfferPage({required this.trade});

  final List<Map<String, dynamic>> tradeRequests = [
    {'name': 'Mango', 'image': 'assets/images/mango.png', 'quantity': '2 kg'},
    {
      'name': 'Strawberry',
      'image': 'assets/images/strawberry.png',
      'quantity': '1 kg',
    },
    {'name': 'Onion', 'image': 'assets/images/onion.png', 'quantity': '½ kg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Trade Offer', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image + Gradient Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F4A2C), Color(0xFFC3E956)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [Image.asset(trade['image'], height: 140)],
                ),
              ),
              SizedBox(height: 16),

              // Category / Name / Quantity (centered)
              Text(
                "Fruit",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                trade['name'],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(trade['quantity'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),

              // Product Details
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Picked at the peak of ripeness, our fresh red tomatoes bring natural sweetness. "
                  "Bursting with juice, they're perfect for salad.",
                  style: TextStyle(fontSize: 15),
                ),
              ),

              SizedBox(height: 20),

              // Preferred Trades
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preferred Trades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Grapes"),
                    Text("• Apples"),
                    Text("• Sitaw"),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Trade Requests
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Trade Requests",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),

              Column(
                children: tradeRequests.map((req) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFC3E956),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Image
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(req['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),

                        // Product Name & Quantity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                req['quantity'],
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Accept Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Accept"),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// paghihiwalayin pa ito sa ibat ibang files :3 but ito na muna for working view ng Trades
/// note ginawa ko po ito gamit web view kaya sorry po if magulo sa part ninyo yung formatting, sorry agad