class PendingMessage {
  final String content;
  final String? clientId;
  final String messageType;
  final Map<String, dynamic>? attachment;
  final String idempotencyKey;
  final DateTime timestamp;

  PendingMessage({
    required this.content,
    this.clientId,
    required this.messageType,
    this.attachment,
    required this.idempotencyKey,
    required this.timestamp,
  });
}
