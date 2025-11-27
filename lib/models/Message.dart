class Message {
  final String sender;
  final String lastMessage;
  final String text;
  final DateTime time;
  final bool isMe;

  Message({
    required this.sender,
    required this.lastMessage,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
