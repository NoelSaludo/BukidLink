import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class PostTimestamp extends StatelessWidget {
  final String timestamp;
  const PostTimestamp({
    super.key,
    required this.timestamp
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
      style: TextStyle(
        fontSize: 12.0,         // smaller, subtle
        color: Colors.grey[600], // muted gray
        fontWeight: FontWeight.normal,
      ),
        timestamp
        ),
    );
  }
}