import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/models/Message.dart';
import 'package:bukidlink/pages/ChatPage.dart';
import 'package:google_fonts/google_fonts.dart';


class InboxPage extends StatelessWidget {
  InboxPage({super.key});

  final List<Message> conversations = [
    Message(
      sender: 'Admin',
      lastMessage: 'Your request has been approved.',
      text: 'Your request has been approved.',
      time: DateTime.now(),
      isMe: false,
    ),
    Message(
      sender: 'Farmer John',
      lastMessage: 'Thanks for the help!',
      text: 'Thanks for the help!',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isMe: false,
    ),
    Message(
      sender: 'Agri Support',
      lastMessage: 'We’ll send an update soon.',
      text: 'We’ll send an update soon.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      isMe: false,
    ),
  ];

  String formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.month}/${time.day}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: AppColors.HEADER_GRADIENT_START,
        centerTitle: true,
        title: Text(
          'Inbox',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
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
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final convo = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.HEADER_GRADIENT_START,
              child: Text(
                convo.sender[0],
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              convo.sender,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              convo.lastMessage,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              formatTime(convo.time),
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(sender: convo.sender),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


