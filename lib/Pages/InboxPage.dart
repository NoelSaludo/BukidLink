import 'package:flutter/material.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';
import 'package:bukidlink/pages/ChatPage.dart';
import 'package:bukidlink/services/ChatService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bukidlink/utils/constants/AppTextStyles.dart';
import 'package:bukidlink/widgets/common/CustomBottomNavBar.dart';

class InboxPage extends StatefulWidget {
  InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final ChatService _chatService = ChatService();
  final Map<String, String> _usernameCache = {};
  final Set<String> _loadingUsernames = {};

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
    // Do not rely on a single static uid here; we listen to auth state below.
    return Scaffold(
      appBar: (UserService.currentUser?.type ?? 'Consumer') == 'Consumer'
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.HEADER_GRADIENT_START,
              elevation: 0,
              title: const Text(
                'Inbox',
                style: AppTextStyles.PRODUCT_INFO_TITLE,
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.HEADER_GRADIENT_START,
                      AppColors.HEADER_GRADIENT_END,
                    ],
                  ),
                ),
              ),
            )
          : AppBar(
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
      body: StreamBuilder<fb_auth.User?>(
        stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnap) {
          final currentUid = authSnap.data?.uid ?? UserService.currentUser?.id;
          if (currentUid == null) {
            return const Center(child: Text('Please sign in to view messages'));
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.streamConversationsForUser(currentUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final convos = snapshot.data ?? [];
              if (convos.isEmpty) {
                return const Center(child: Text('No conversations'));
              }

              // Prefetch usernames for display
              final Set<String> otherIds = {};
              for (final conv in convos) {
                final partsRaw = (conv['participants'] as List<dynamic>?) ?? [];
                final List<String> participants = partsRaw
                    .map((p) {
                      if (p == null) return '';
                      if (p is String) return p;
                      if (p is DocumentReference) return p.id;
                      if (p is Map && p['id'] != null)
                        return p['id'].toString();
                      return p.toString();
                    })
                    .where((s) => s.isNotEmpty)
                    .toList();

                String otherId = conv['id'] as String? ?? '';
                if (currentUid.isNotEmpty && participants.isNotEmpty) {
                  otherId = participants.firstWhere(
                    (p) => p != currentUid,
                    orElse: () => participants.first,
                  );
                } else if (participants.isNotEmpty) {
                  otherId = participants.first;
                }
                if (otherId.isNotEmpty) otherIds.add(otherId);
              }

              final missing = otherIds
                  .where(
                    (id) =>
                        !_usernameCache.containsKey(id) &&
                        !_loadingUsernames.contains(id),
                  )
                  .toList();
              if (missing.isNotEmpty) _prefetchUsernames(missing);

              return ListView.builder(
                itemCount: convos.length,
                itemBuilder: (context, index) {
                  final conv = convos[index];
                  final partsRaw =
                      (conv['participants'] as List<dynamic>?) ?? [];
                  final List<String> participants = partsRaw
                      .map((p) {
                        if (p == null) return '';
                        if (p is String) return p;
                        if (p is DocumentReference) return p.id;
                        if (p is Map && p['id'] != null)
                          return p['id'].toString();
                        return p.toString();
                      })
                      .where((s) => s.isNotEmpty)
                      .toList();

                  String otherId = conv['id'] as String? ?? '';
                  if (currentUid.isNotEmpty && participants.isNotEmpty) {
                    otherId = participants.firstWhere(
                      (p) => p != currentUid,
                      orElse: () => participants.first,
                    );
                  } else if (participants.isNotEmpty) {
                    otherId = participants.first;
                  }

                  final lastMsg = (conv['lastMessage'] as String?) ?? '';
                  final updated = conv['updatedAt'] as Timestamp?;
                  final time = updated != null
                      ? updated.toDate()
                      : DateTime.now();

                  final displayName = _usernameCache[otherId] ?? otherId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.HEADER_GRADIENT_START,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      displayName,
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
          );
        },
      ),
      bottomNavigationBar:
          (UserService.currentUser?.type ?? 'Consumer') == 'Consumer'
          ? const CustomBottomNavBar(currentIndex: 2)
          : null,
    );
  }

  Future<void> _prefetchUsernames(List<String> ids) async {
    for (final id in ids) {
      if (_usernameCache.containsKey(id) || _loadingUsernames.contains(id))
        continue;
      _loadingUsernames.add(id);
    }

    final List<Future<void>> futures = ids.map((id) async {
      if (_usernameCache.containsKey(id)) return;
      try {
        final user = await UserService().getUserById(id);
        final name = user?.username ?? id;
        if (mounted) {
          setState(() {
            _usernameCache[id] = name;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _usernameCache[id] = id;
          });
        }
      } finally {
        _loadingUsernames.remove(id);
      }
    }).toList();

    await Future.wait(futures);
  }
}
