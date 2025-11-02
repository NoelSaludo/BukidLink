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
      child: Column(children: [
        SizedBox(
          
          child: Text(
          username,
          style: AppTextStyles.PRODUCT_NAME_LARGE,
          ),
        ),
        Text(
          farmName,
          style: AppTextStyles.farmName,
        )
      ]),
    );
  }
}
