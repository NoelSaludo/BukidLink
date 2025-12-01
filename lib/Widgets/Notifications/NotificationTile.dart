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
        final pic = (poster?.profilePic ?? 'default_profile.png').replaceFirst(RegExp(r'^/+'), '');
        imageUrl += pic;
        break;
      case 'shipping':
        imageUrl = 'shipping.png';
        break;
      case 'message':
        final pic = (messenger?.profilePic ?? 'default_profile.png').replaceFirst(RegExp(r'^/+'), '');
        imageUrl += pic;
        break;
      case 'system':
        imageUrl = 'systemNotif.png';
        break;
      default:
        imageUrl = 'systemNotif.png';
    }
    return InkWell(
      onTap: () { onTapped(context, notification.type);},
      child: Container(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Profile / Notification Icon with border
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green.shade200, width: 2),
        ),
        child: ClipOval(
          child: NotificationIcon(imageUrl: imageUrl),
        ),
      ),

      const SizedBox(width: 12),

      // Text section
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: NotificationTitle(
                    title: notification.title,
                  ),
                ),
                NotificationTimestamp(
                  timestamp: formatter.format(notification.timestamp),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Body text
            NotificationBody(
              body: notification.body,

            ),

            const SizedBox(height: 6),

            // Optional divider accent line
            Container(
              height: 2,
              width: 40,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
)

    );
  }
}
