import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/models/Message.dart';
import 'package:bukidlink/Widgets/message/MessageBubble.dart';
import 'package:bukidlink/services/ChatService.dart';
import 'package:bukidlink/services/UserService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bukidlink/utils/constants/AppColors.dart';

class ChatPage extends StatefulWidget {
  final String sender;

  const ChatPage({super.key, required this.sender});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  StreamSubscription<List<Message>>? _messagesSub;
  String? _conversationId;
  String? _currentUid;
  String? _senderName;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _currentUid = UserService.currentUser?.id ?? 'you123';
    _conversationId = _chatService.conversationIdFor(
      _currentUid!,
      widget.sender,
    );
    _fetchSenderName();
    _scrollController.addListener(_onScroll);
    _initConversation();
  }

  Future<void> _fetchSenderName() async {
    try {
      final user = await UserService().getUserById(widget.sender);
      if (mounted) {
        setState(() {
          _senderName = user?.username ?? widget.sender;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _senderName = widget.sender;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // if we're at the top, load more
    if (_scrollController.position.pixels <= 0) {
      _loadMoreMessages();
    }
  }

  Future<void> _initConversation() async {
    if (_conversationId == null || _currentUid == null) return;
    await _chatService.createConversation(_currentUid!, widget.sender);
    await _loadInitialMessages();

    _messagesSub = _chatService
        .streamMessages(_conversationId!, limit: 200)
        .listen((incoming) {
          _mergeMessages(incoming);
          _scrollToBottom();
        });
  }

  Future<void> _loadInitialMessages() async {
    if (_conversationId == null) return;
    final msgs = await _chatService.fetchMessages(
      _conversationId!,
      limit: _pageSize,
    );
    setState(() {
      _messages.clear();
      _messages.addAll(msgs);
    });
    _scrollToBottom();
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMore) return;
    if (_conversationId == null) return;
    if (_messages.isEmpty) return;

    _isLoadingMore = true;
    try {
      final oldest = _messages.first;
      final beforeTs = Timestamp.fromDate(oldest.time);
      final older = await _chatService.fetchMessages(
        _conversationId!,
        limit: _pageSize,
        before: beforeTs,
      );
      if (older.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          // prepend older messages
          _messages.insertAll(0, older);
        });
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  void _mergeMessages(List<Message> incoming) {
    if (incoming.isEmpty) return;
    final Map<String, Message> keyed = {};
    for (final m in _messages) {
      final key =
          '${m.senderId}_${m.time.millisecondsSinceEpoch}_${m.text.hashCode}';
      keyed[key] = m;
    }
    for (final m in incoming) {
      final key =
          '${m.senderId}_${m.time.millisecondsSinceEpoch}_${m.text.hashCode}';
      keyed[key] = m;
    }

    final merged = keyed.values.toList();
    merged.sort(
      (a, b) => a.time.millisecondsSinceEpoch.compareTo(
        b.time.millisecondsSinceEpoch,
      ),
    );
    setState(() {
      _messages
        ..clear()
        ..addAll(merged);
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_conversationId == null || _currentUid == null) return;

    _chatService.sendMessage(_conversationId!, _currentUid!, text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } catch (_) {}
    });
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
          _senderName ?? widget.sender,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.outfit(),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.grey.shade500,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.HEADER_GRADIENT_START,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
