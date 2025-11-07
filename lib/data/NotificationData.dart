import 'package:bukidlink/models/AppNotification.dart';
import 'package:flutter/material.dart';

class NotificationData {
  static final List<AppNotification> _allNotifications = [
    // Notifications
    AppNotification(
      id: '1',
      title: 'Recently Posted',
      body: 'Tindahan ni Lourdes made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '1',
      },
      type: 'post',
      clickAction: '/profile',
    ),
    AppNotification(
      id: '2',
      title: 'Recently Posted',
      body: 'Fernandez Domingo made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '2',
      },
      type: 'post',
      clickAction: '/profile',
    ),
     AppNotification(
      id: '4',
      title: 'Recently Posted',
      body: 'FarmJuseyo made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '3',
      },
      type: 'post',
      clickAction: '/profile',
    ),
  ];

  // Get all Notifications
  static List<AppNotification> getAllNotifications() {
    return _allNotifications;
  }
}
