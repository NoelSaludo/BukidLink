import 'package:flutter/material.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostIcon extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTapped;
  const PostIcon({
    super.key,
    required this.imageUrl,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    String image = 'assets/images/';
    image += imageUrl;
    return InkWell(
      onTap: onTapped,
      child: Container(
      child: Image.asset(image),
      ),
    );
  }
}
