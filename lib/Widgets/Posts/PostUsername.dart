import 'package:bukidlink/Utils/constants/AppTextStyles.dart';
import 'package:flutter/material.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostUsername extends StatelessWidget {
  final String username;
  final String farmName;
  const PostUsername({
    super.key,
    required this.username,
    required this.farmName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(
          child: Text(
          username,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          ),
        ),
        Text(
          farmName,
          
          style: TextStyle(
            fontSize: 13.0,        // slightly larger than post content
            color: Colors.grey,    // more prominent// semi-bold
          ),
        )
      ]),
    );
  }
}