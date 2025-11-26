import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/pages/ChatPage.dart';
import 'package:bukidlink/services/ChatService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxPage extends StatefulWidget {
  InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final ChatService _chatService = ChatService();
  String? _currentUid;

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
    final uid = UserService.currentUser?.id;
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.streamConversationsForUser(uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final convos = snapshot.data ?? [];
          if (convos.isEmpty) {
            return const Center(child: Text('No conversations'));
          }
          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final conv = convos[index];
              final partsRaw = (conv['participants'] as List<dynamic>?) ?? [];
              final List<String> participants = partsRaw
                  .map((p) {
                    if (p == null) return '';
                    if (p is String) return p;
                    if (p is DocumentReference) return p.id;
                    if (p is Map && p['id'] != null) return p['id'].toString();
                    return p.toString();
                  })
                  .where((s) => s.isNotEmpty)
                  .toList();
              String otherId = conv['id'] as String? ?? '';
              if (uid != null && participants.isNotEmpty) {
                otherId = participants.firstWhere(
                  (p) => p != uid,
                  orElse: () => participants.first,
                );
              } else if (participants.isNotEmpty) {
                otherId = participants.first;
              }

              final lastMsg = (conv['lastMessage'] as String?) ?? '';
              final updated = conv['updatedAt'] as Timestamp?;
              final time = updated != null ? updated.toDate() : DateTime.now();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.HEADER_GRADIENT_START,
                  child: Text(
                    otherId.isNotEmpty ? otherId[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  otherId,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  lastMsg,
                  style: GoogleFonts.outfit(color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  formatTime(time),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(sender: otherId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
