import 'package:flutter/material.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
// import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
// import 'package:bukidlink/data/NotificationData.dart';
// import 'package:bukidlink/Utils/PageNavigator.dart';

class ProfileInfo extends StatelessWidget {
  final String body;
  
  const ProfileInfo({
    super.key,
    required this.body
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(body),
    );
  }
}
