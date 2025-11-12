class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // any extra payload
  final String type;
  final String clickAction;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    DateTime? timestamp,
    required this.clickAction,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();


  /// Convert model to JSON (for saving or sending)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'type': type,
      'clickAction': clickAction,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// Copy with updated fields (useful when marking as read)
  AppNotification copyWith({
    String? title,
    String? body,
    String? imageUrl,
    String? clickAction,
    Map<String, dynamic>? data,
    String? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      clickAction: clickAction ?? this.clickAction,
    );
  }
}
