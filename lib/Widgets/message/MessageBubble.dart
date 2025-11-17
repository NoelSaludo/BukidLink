import 'package:flutter/material.dart';
import 'package:bukidlink/models/Message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment =
    message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color =
    message.isMe ? Colors.green.shade300 : Colors.grey.shade300;
    final textColor =
    message.isMe ? Colors.white : Colors.black87;
    final radius = message.isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(0),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            color: Colors.black, // default text color
          ),
        ),
      ),
    );
  }
}
