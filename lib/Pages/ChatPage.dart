import 'package:flutter/material.dart';
import 'package:bukidlink/models/Message.dart';
import 'package:bukidlink/Widgets/message/MessageBubble.dart';
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
  final List<Message> _messages = [
    Message(
      sender: 'Admin',
      senderId: 'admin123',
      receiverId: 'you123',
      lastMessage: '',
      text: 'Hello! How can I help you?',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
    Message(
      sender: 'You',
      senderId: 'you123',
      receiverId: 'admin123',
      lastMessage: '',
      text: 'I have a question about my crops.',
      time: DateTime.now().subtract(const Duration(minutes: 4)),
      isMe: true,
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          sender: 'You',
          senderId: 'you123',
          receiverId: 'admin123',
          lastMessage: '',
          text: _controller.text.trim(),
          time: DateTime.now(),
          isMe: true,
        ),
      );
      _controller.clear();
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
          widget.sender,
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
