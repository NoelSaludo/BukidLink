import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sender;
  final String senderId;
  final String text;
  final DateTime time;
  final bool isMe;

  Message({
    required this.sender,
    required this.senderId,
    // lastMessage removed
    required this.text,
    required this.time,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      sender: json['sender'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      time: (json['time'] as Timestamp).toDate(),
      isMe: json['senderId'] == currentUserId,
    );
  }

  Message copyWith({
    String? sender,
    String? senderId,
    String? text,
    DateTime? time,
    bool? isMe,
  }) {
    return Message(
      sender: sender ?? this.sender,
      senderId: senderId ?? this.senderId,
      // lastMessage removed
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
    );
  }

  Map<String, dynamic> toDocument({bool useServerTimestamp = false}) {
    return {
      'sender': sender,
      'senderId': senderId,
      // lastMessage removed
      'text': text,
      'time': useServerTimestamp
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(time),
    };
  }
}
