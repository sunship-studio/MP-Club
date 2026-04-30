class Message {
  final String id;
  final String clientId;
  final String content;
  final bool fromShane;
  final DateTime timestamp;
  final String messageType;
  final Map<String, dynamic>? attachment;
  final MessageStatus status;

  Message({
    required this.id,
    required this.clientId,
    required this.content,
    required this.fromShane,
    required this.timestamp,
    this.messageType = 'text',
    this.attachment,
    required this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      clientId: json['client_id'],
      content: json['content'] ?? '',
      fromShane: json['fromShane'],
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      messageType: json['message_type'] ?? 'text',
      attachment: json['attachment'],
      status: MessageStatus.fromJson(json['status'] ?? {}),
    );
  }
}

class MessageStatus {
  DateTime? delivered;
  DateTime? read;

  MessageStatus({this.delivered, this.read});

  factory MessageStatus.fromJson(Map<String, dynamic> json) {
    return MessageStatus(
      delivered:
          json['delivered'] != null ? DateTime.parse(json['delivered']) : null,
      read: json['read'] != null ? DateTime.parse(json['read']) : null,
    );
  }
}
