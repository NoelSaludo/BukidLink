import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Posts/PostImage.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostContent extends StatelessWidget {
  final String textContent;
  final String imageUrl;
  final String? heroTag;

  const PostContent({
    super.key,
    required this.textContent,
    required this.imageUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
      return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
            alignment: Alignment.topLeft,
            child: Text(
              textContent,
              style: TextStyle(
                fontSize: 14.0,        // slightly smaller than username
                color: Colors.black87,  // soft black for readability
                height: 1.4,           // line spacing for legibility
                fontWeight: FontWeight.normal,
              ),
),),
          const SizedBox(height: 20.0),
          if(imageUrl.isNotEmpty) 
          PostImage(imagePath: imageUrl, heroTag: heroTag)
        ]),
    );
  }
}