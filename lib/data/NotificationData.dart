import 'package:bukidlink/models/AppNotification.dart';
import 'package:flutter/material.dart';

class NotificationData {
  static final List<AppNotification> _allNotifications = [
    // Fruits
    AppNotification(
      id: '1',
      title: 'Recently Posted',
      body: 'Test User made a new post that might interest you.',
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
      body: 'Test User made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '1',
      },
      type: 'post',
      clickAction: '/profile',
    ),
     AppNotification(
      id: '3',
      title: 'Recently Posted',
      body: 'Test User made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '1',
      },
      type: 'post',
      clickAction: '/profile',
    ),
     AppNotification(
      id: '4',
      title: 'Recently Posted',
      body: 'Test User made a new post that might interest you.',
      timestamp: DateTime(2025, 10, 10, 10, 30),
      isRead: false,
      data: {
        'posterID': '1',
      },
      type: 'post',
      clickAction: '/profile',
    ),
  ];

  // Get all Consumers
  static List<AppNotification> getAllNotifications() {
    return _allNotifications;
  }
}
