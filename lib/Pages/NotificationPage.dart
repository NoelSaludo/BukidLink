import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';
import 'package:bukidlink/data/NotificationData.dart';
import 'package:bukidlink/models/AppNotification.dart';
import 'package:bukidlink/Widgets/Notifications/NotificationTile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppNotification> notifications;

  final List<String> _tabs = ['All', 'post', 'message', 'system'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    notifications = NotificationData.getAllNotifications();
  }

  List<AppNotification> _filteredNotifications(String type) {
    if (type == 'All') return notifications;
    return notifications.where((n) => n.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundYellow,
      appBar: AppBar(
          // Header with gradient and tabs
          automaticallyImplyLeading: false,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.PRODUCT_INFO_TITLE),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.HEADER_GRADIENT_START,
                AppColors.HEADER_GRADIENT_END,
              ],
            ),
          ),
        ),
                // Centered tab bar
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: _tabs
                      .map((tab) =>
                          Tab(text: tab[0].toUpperCase() + tab.substring(1)))
                      .toList(),
                ),
            ),

          // Notification content
            body: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                final filtered = _filteredNotifications(tab);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No $tab notifications',
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8), // reduce top space
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final notification = filtered[index];
                    return NotificationTile(notification: notification);
                  },
                );
              }).toList(),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
