import 'package:flutter/material.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostContent extends StatelessWidget {
  final String textContent;
  final String imageContent;
  
  const PostContent({
    super.key,
    required this.textContent,
    required this. imageContent,
  });

  @override
  Widget build(BuildContext context) {
      String imageUrl = 'assets/images/';
      imageUrl += imageContent;
      return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
            alignment: Alignment.topLeft,
            child: Text(textContent),),
          const SizedBox(height: 5.0),
          Image.asset(imageUrl),
        ]),
    );
  }
}
