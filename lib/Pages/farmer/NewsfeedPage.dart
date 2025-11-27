import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';

class NewsfeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const FarmerAppBar(),
          Expanded(
            child: Center(
              child: Text('Newsfeed Page', style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 2),
    );
  }
}
