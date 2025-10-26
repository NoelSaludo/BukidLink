import 'package:flutter/material.dart';
// import 'package:bukidlink/utils/PageNavigator.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context){
    return Container(
      child: Padding(
        padding: EdgeInsetsGeometry.all(30.0),
        child: InkWell(
              onTap: () {
                // Define what happens when the button is tapped
                onPressed();
              },
              borderRadius: BorderRadius.circular(8.0), // Match Material's border radius
              child: Image.asset(
                'assets/BackIcon.png',
                fit: BoxFit.cover, // Adjust how the image fits
                width: 25.0,
                height: 23.0,
              ),
            ),
        )
            // elevation: 4.0, // Add a shadow for better visual appearance
    );
  }
}