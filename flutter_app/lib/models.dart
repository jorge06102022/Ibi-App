class Room {
  final String slug;
  final String displayName;
  final int messageCount;
  final String lastActivity;

  Room({
    required this.slug,
    required this.displayName,
    required this.messageCount,
    required this.lastActivity,
  });

  factory Room.fromJson(Map<String, dynamic> j) => Room(
        slug: j['slug'] as String,
        displayName: j['display_name'] as String,
        messageCount: (j['message_count'] as num?)?.toInt() ?? 0,
        lastActivity: j['last_activity'] as String? ?? '',
      );
}

class ChatMessage {
  final int? msgId;
  final String senderName;
  final String senderColor;
  final String content;
  final String messageType; // 'text' | 'voice'
  final String timestamp;
  final bool isOwn;

  ChatMessage({
    this.msgId,
    required this.senderName,
    required this.senderColor,
    required this.content,
    required this.messageType,
    required this.timestamp,
    this.isOwn = false,
  });
}
