import 'package:flutter/material.dart';
import 'package:bukidlink/Widgets/Notifications/NotificationIcon.dart';
import 'package:bukidlink/Widgets/Notifications/NotificationTitle.dart';
import 'package:bukidlink/Widgets/Notifications/NotificationBody.dart';
import 'package:bukidlink/Widgets/Notifications/NotificationTimestamp.dart';
import 'package:bukidlink/data/NotificationData.dart';
import 'package:bukidlink/models/AppNotification.dart';
import 'package:bukidlink/Utils/PageNavigator.dart';
import 'package:bukidlink/data/UserData.dart';
import 'package:bukidlink/models/User.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const NotificationTile({
    super.key,
    required this.notification,
  });

  void onTapped (context, String type){
    switch(type){
      case 'post':  Navigator.pushNamed(
        context, 
        notification.clickAction,
        arguments: notification.data!['posterID']);
      break;
      case 'message': Navigator.pushNamed(
        context, 
        notification.clickAction,
        arguments: notification.data!['posterID']);
      break;
      case 'shipping': Navigator.pushNamed(
        context, 
        notification.clickAction,
        arguments: notification.data);
      break;
      case 'system': Navigator.pushNamed(
        context, 
        notification.clickAction,);
      break;
      default: Navigator.pushNamed(
        context, 
        notification.clickAction,
        arguments: notification.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('MMM d, yyyy · H:mm a');
    //notification icon
    User? poster;
    if (notification.data != null && notification.data!['posterID'] != null) {
      poster = UserData.getUserById(notification.data!['posterID']);
    }

    User? messenger;
    if (notification.data != null && notification.data!['messengerID'] != null) {
      messenger = UserData.getUserById(notification.data!['messengerID']);
    }
   //if type message
    String imageUrl = 'assets/images/';
    switch (notification.type) {
      case 'post':
        imageUrl += poster?.profilePic ?? 'assets/images/default_profile.png';
      break;
      case 'shipping':
        imageUrl = 'assets/images/shipping.png';
      break;
      case 'message':
        imageUrl += messenger?.profilePic ?? 'assets/images/default_profile.png';
      break;
      case 'system':
        imageUrl = 'assets/images/systemNotif.png';
      break;
      default:
        imageUrl = 'assets/images/systemNotif.png';
}
    return InkWell(
      onTap: () { onTapped(context, notification.type);},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Notification icon
            NotificationIcon(imageUrl: imageUrl),

            const SizedBox(width: 10),

            // Right: Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationTitle(title: notification.title),
                  const SizedBox(height: 4),
                  NotificationBody(body: notification.body),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: NotificationTimestamp(
                      timestamp: formatter.format(notification.timestamp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
