import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mpc_mobile_app/data/models/message.dart';
import 'package:mpc_mobile_app/data/models/pending_message.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
  error,
}

class TypingIndicator {
  final bool isTyping;
  final bool fromShane;

  TypingIndicator({required this.isTyping, required this.fromShane});

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    print("TypingIndicator json: $json");
    return TypingIndicator(
      isTyping: json['isTyping'],
      fromShane: json['fromShane'],
    );
  }
}

class ReadReceipt {
  final String clientId;
  final DateTime readAt;
  final bool byShane;

  ReadReceipt({
    required this.clientId,
    required this.readAt,
    required this.byShane,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      clientId: json['clientId'],
      readAt: DateTime.parse(json['readAt']),
      byShane: json['byShane'],
    );
  }
}

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  final _connectionSubject = BehaviorSubject<ConnectionStatus>.seeded(
    ConnectionStatus.disconnected,
  );
  final _messageSubject = PublishSubject<Message>();
  final _typingSubject = PublishSubject<TypingIndicator>();
  final _readReceiptSubject = PublishSubject<ReadReceipt>();
  final _unreadCountSubject = BehaviorSubject<int>.seeded(0);
  final _shaneStatusSubject = BehaviorSubject<bool>.seeded(false);

  Timer? _reconnectTimer;
  Timer? _typingTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 1);

  final List<PendingMessage> _messageQueue = [];
  bool _isProcessingQueue = false;

  Stream<ConnectionStatus> get connectionStream => _connectionSubject.stream;
  Stream<Message> get messageStream => _messageSubject.stream;
  Stream<TypingIndicator> get typingStream => _typingSubject.stream;
  Stream<ReadReceipt> get readReceiptStream => _readReceiptSubject.stream;
  Stream<int> get unreadCountStream => _unreadCountSubject.stream;
  Stream<bool> get shaneStatusStream => _shaneStatusSubject.stream;

  ConnectionStatus get status => _connectionSubject.value;
  bool get isConnected => _socket?.connected ?? false;
  int get unreadCount => _unreadCountSubject.value;
  bool get isShaneOnline => _shaneStatusSubject.value;

  Future<void> connect(
    String serverUrl,
    String token,
    String refreshToken,
  ) async {
    print("Is Connected: $isConnected");
    if (isConnected) {
      debugPrint('Socket already connected');
      return;
    }

    _connectionSubject.add(ConnectionStatus.connecting);

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token, 'refreshToken': refreshToken})
          .build(),
    );

    _setupListeners();
    _startHeartbeat();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('✅ Socket connected');
      _connectionSubject.add(ConnectionStatus.connected);
      _socket!.connected = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _processMessageQueue();
    });

    _socket?.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
      _connectionSubject.add(ConnectionStatus.disconnected);
      _attemptReconnect();
    });

    _socket?.onConnectError((error) {
      debugPrint('Connection error: $error');
      _connectionSubject.add(ConnectionStatus.error);
    });

    _socket?.on('initial:data', (data) {
      print("initial data: $data");
      final unreadCount = data[0]['unreadCount'];
      final shaneOnline = data[0]['isUserOnline'] ?? false;
      if (unreadCount is int) {
        _unreadCountSubject.add(unreadCount);
      }
      _shaneStatusSubject.add(shaneOnline);
    });

    _socket?.on('message:new', (data) {
      final message = Message.fromJson(data[0]);
      _messageSubject.add(message);
    });

    _socket?.on('typing:status', (data) {
      print("typing data: $data");
      final indicator = TypingIndicator.fromJson(data[0]);
      _typingSubject.add(indicator);
    });

    _socket?.on('messages:read-receipt', (data) {
      final receipt = ReadReceipt.fromJson(data[0]);
      _readReceiptSubject.add(receipt);
    });

    _socket?.on('unread:update', (data) {
      final count = data[0]['count'] ?? data[0]['total'] ?? 0;
      _unreadCountSubject.add(count);
    });

    _socket?.on('shane:presence', (data) {
      final isOnline = data[0]['online'] == true;
      _shaneStatusSubject.add(isOnline);
    });
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('❌ Max reconnect attempts reached');
      _connectionSubject.add(ConnectionStatus.error);
      return;
    }

    final delay = _baseReconnectDelay * (1 << _reconnectAttempts);
    _reconnectAttempts++;
    _connectionSubject.add(ConnectionStatus.reconnecting);

    _reconnectTimer = Timer(delay, () {
      debugPrint('🔄 Reconnecting... (Attempt $_reconnectAttempts)');
      _socket?.connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isConnected) {
        _socket?.emit('ping');
      }
    });
  }

  Future<void> sendMessage({
    required String content,
    String? clientId,
    String messageType = 'text',
    Map<String, dynamic>? attachment,
  }) async {
    final idempotencyKey =
        '${DateTime.now().millisecondsSinceEpoch}_${content.hashCode}';

    final pendingMessage = PendingMessage(
      content: content,
      clientId: clientId,
      messageType: messageType,
      attachment: attachment,
      idempotencyKey: idempotencyKey,
      timestamp: DateTime.now(),
    );

    if (!isConnected) {
      _messageQueue.add(pendingMessage);
      throw Exception('Offline. Message queued.');
    }

    return _sendMessageInternal(pendingMessage);
  }

  Future<void> _sendMessageInternal(PendingMessage pending) async {
    final completer = Completer<void>();

    _socket?.emitWithAck(
      'message:send',
      {
        'content': pending.content,
        if (pending.clientId != null) 'clientId': pending.clientId,
        'message_type': pending.messageType,
        if (pending.attachment != null) 'attachment': pending.attachment,
        'idempotencyKey': pending.idempotencyKey,
      },
      ack: (response) {
        if (response['success'] == true) {
          completer.complete();
        } else {
          completer.completeError(response['error'] ?? 'SEND_FAILED');
        }
      },
    );

    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<void> _processMessageQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_messageQueue.isNotEmpty && isConnected) {
      final message = _messageQueue.removeAt(0);
      try {
        await _sendMessageInternal(message);
      } catch (e) {
        _messageQueue.insert(0, message);
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _isProcessingQueue = false;
  }

  Future<List<Message>> loadMessages({
    String? clientId,
    DateTime? before,
    int limit = 50,
  }) async {
    if (!isConnected) throw Exception('Not connected');

    final completer = Completer<List<Message>>();

    _socket?.emitWithAck(
      'messages:load',
      {
        if (clientId != null) 'clientId': clientId,
        if (before != null) 'before': before.toIso8601String(),
        'limit': limit,
      },
      ack: (response) {
        if (response['success'] == true) {
          final messages =
              (response['messages'] as List).map((m) {
                return Message.fromJson(m);
              }).toList();
          completer.complete(messages);
        } else {
          completer.completeError(response['error'] ?? 'LOAD_FAILED');
        }
      },
    );

    return completer.future.timeout(const Duration(seconds: 10));
  }

  void startTyping({String? clientId}) {
    if (!isConnected) return;
    _socket?.emit('typing:start', {if (clientId != null) 'clientId': clientId});

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping(clientId: clientId);
    });
  }

  void stopTyping({String? clientId}) {
    _typingTimer?.cancel();
    if (!isConnected) return;
    _socket?.emit('typing:stop', {if (clientId != null) 'clientId': clientId});
  }

  Future<void> markMessagesAsRead({
    String? clientId,
    List<String>? messageIds,
  }) async {
    print(
      'Marking messages as read: clientId=$clientId, messageIds=$messageIds',
    );
    if (!isConnected) return;
    _socket?.emitWithAck('messages:mark-read', {
      if (clientId != null) 'clientId': clientId,
      if (messageIds != null) 'messageIds': messageIds,
    });
  }

  void disconnect() {
    _typingTimer?.cancel();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionSubject.add(ConnectionStatus.disconnected);
  }

  Future<void> dispose() async {
    disconnect();
    await _connectionSubject.close();
    await _messageSubject.close();
    await _typingSubject.close();
    await _readReceiptSubject.close();
    await _unreadCountSubject.close();
    await _shaneStatusSubject.close();
  }
}
