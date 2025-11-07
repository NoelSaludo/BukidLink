import 'package:flutter/material.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class NotificationTimestamp extends StatelessWidget {
  final String timestamp;
  const NotificationTimestamp({
    super.key,
    required this.timestamp
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        timestamp,
        style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),),
    );
  }
}
