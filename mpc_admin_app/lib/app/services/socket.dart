import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mpc_admin_app/app/models/message.dart';
import 'package:mpc_admin_app/app/models/pending_message.dart';
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
  final String clientId;

  final bool isTyping;
  final bool fromShane;

  TypingIndicator({
    required this.clientId,

    required this.isTyping,
    required this.fromShane,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    debugPrint('TypingIndicator fromJson: $json');
    return TypingIndicator(
      clientId: json['clientId'],

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

// New class to track client-specific unread counts
class ClientUnreadCount {
  final String clientId;
  final String clientName;
  final int unreadCount;
  final DateTime? lastMessageTime;

  ClientUnreadCount({
    required this.clientId,
    required this.clientName,
    required this.unreadCount,
    this.lastMessageTime,
  });

  factory ClientUnreadCount.fromJson(Map<String, dynamic> json) {
    return ClientUnreadCount(
      clientId: json['clientId'],
      clientName: json['clientName'] ?? 'Unknown Client',
      unreadCount: json['unreadCount'] ?? 0,
      lastMessageTime:
          json['lastMessageTime'] != null
              ? DateTime.parse(json['lastMessageTime'])
              : null,
    );
  }

  ClientUnreadCount copyWith({
    String? clientId,
    String? clientName,
    int? unreadCount,
    DateTime? lastMessageTime,
  }) {
    return ClientUnreadCount(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
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

  // Changed: Now tracks unread counts per client
  final _clientUnreadCountsSubject =
      BehaviorSubject<Map<String, ClientUnreadCount>>.seeded({});

  // Keep total unread count for convenience
  final _totalUnreadCountSubject = BehaviorSubject<int>.seeded(0);

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

  // New: Stream of all client unread counts
  Stream<Map<String, ClientUnreadCount>> get clientUnreadCountsStream =>
      _clientUnreadCountsSubject.stream;

  // Stream for specific client unread count
  Stream<int> getClientUnreadCountStream(String clientId) {
    return _clientUnreadCountsSubject.stream.map(
      (counts) => counts[clientId]?.unreadCount ?? 0,
    );
  }

  // Total unread count across all clients
  Stream<int> get totalUnreadCountStream => _totalUnreadCountSubject.stream;

  Stream<bool> get shaneStatusStream => _shaneStatusSubject.stream;

  ConnectionStatus get status => _connectionSubject.value;
  bool get isConnected => _socket?.connected ?? false;

  // Get unread count for specific client
  int getClientUnreadCount(String clientId) {
    return _clientUnreadCountsSubject.value[clientId]?.unreadCount ?? 0;
  }

  // Get all client unread counts
  Map<String, ClientUnreadCount> get allClientUnreadCounts =>
      _clientUnreadCountsSubject.value;

  // Total unread count
  int get totalUnreadCount => _totalUnreadCountSubject.value;

  bool get isShaneOnline => _shaneStatusSubject.value;

  Future<void> connect(String serverUrl, String token) async {
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
          .setAuth({'token': token})
          .build(),
    );

    _setupListeners();
    _startHeartbeat();
  }

  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('✅ Socket connected');
      _connectionSubject.add(ConnectionStatus.connected);
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

    // Modified: Handle initial data with per-client unread counts
    _socket?.on('initial:data', (data) {
      final responseData = data[0];
      final shaneOnline = responseData['isUserOnline'] ?? false;
      print('Initial data received: $responseData');
      // Handle different response formats
      if (responseData['unreadCount'] != null) {
        // New format: per-client unread counts
        final clientCounts = <String, ClientUnreadCount>{};
        final clientUnreadData =
            responseData['unreadCount']['byClient'] as List<dynamic>;

        for (var countData in clientUnreadData) {
          final clientId = countData['_id'] as String;
          clientCounts[clientId] = ClientUnreadCount.fromJson({
            'clientId': clientId,
            ...countData,
          });
        }

        _updateClientUnreadCounts(clientCounts);
      } else if (responseData['unreadCount'] != null) {
        // Fallback: single unread count
        final unreadCount = responseData['unreadCount'];
        if (unreadCount is int) {
          _totalUnreadCountSubject.add(unreadCount);
        }
      }

      _shaneStatusSubject.add(shaneOnline);
    });

    _socket?.on('message:new', (data) {
      final message = Message.fromJson(data[0]);
      _messageSubject.add(message);

      // Update unread count for the client who sent the message
      if (!message.fromShane) {
        _incrementClientUnreadCount(message.clientId);
      }
    });

    _socket?.on('typing:status', (data) {
      print('Typing status data: $data');
      final indicator = TypingIndicator.fromJson(data[0]);
      _typingSubject.add(indicator);
    });

    _socket?.on('messages:read-receipt', (data) {
      final receipt = ReadReceipt.fromJson(data[0]);
      _readReceiptSubject.add(receipt);

      // If Shane read messages, reset unread count for that client
      if (receipt.byShane) {
        _resetClientUnreadCount(receipt.clientId);
      }
    });

    // Modified: Handle per-client unread count updates
    _socket?.on('unread:update', (data) {
      final updateData = data[0];

      if (updateData['clientId'] != null) {
        // Update for specific client
        final clientId = updateData['clientId'] as String;
        final count = updateData['count'] ?? updateData['unreadCount'] ?? 0;
        _updateClientUnreadCount(clientId, count);
      } else if (updateData['clientCounts'] != null) {
        // Bulk update for multiple clients
        final clientCounts = <String, ClientUnreadCount>{};
        final clientCountsData =
            updateData['clientCounts'] as Map<String, dynamic>;

        clientCountsData.forEach((clientId, countData) {
          clientCounts[clientId] = ClientUnreadCount.fromJson({
            'clientId': clientId,
            ...countData,
          });
        });

        _updateClientUnreadCounts(clientCounts);
      } else {
        // Fallback: total count update
        final count = updateData['count'] ?? updateData['total'] ?? 0;
        _totalUnreadCountSubject.add(count);
      }
    });

    _socket?.on('shane:presence', (data) {
      final isOnline = data[0]['online'] == true;
      _shaneStatusSubject.add(isOnline);
    });
  }

  // New methods to handle per-client unread counts
  void _updateClientUnreadCounts(Map<String, ClientUnreadCount> newCounts) {
    _clientUnreadCountsSubject.add(newCounts);

    // Update total count
    final total = newCounts.values.fold<int>(
      0,
      (sum, client) => sum + client.unreadCount,
    );
    _totalUnreadCountSubject.add(total);
  }

  void _updateClientUnreadCount(
    String clientId,
    int count, {
    String? clientName,
  }) {
    final currentCounts = Map<String, ClientUnreadCount>.from(
      _clientUnreadCountsSubject.value,
    );

    if (currentCounts.containsKey(clientId)) {
      currentCounts[clientId] = currentCounts[clientId]!.copyWith(
        unreadCount: count,
      );
    } else {
      currentCounts[clientId] = ClientUnreadCount(
        clientId: clientId,
        clientName: clientName ?? 'Unknown Client',
        unreadCount: count,
        lastMessageTime: DateTime.now(),
      );
    }

    _updateClientUnreadCounts(currentCounts);
  }

  void _incrementClientUnreadCount(String clientId, {String? clientName}) {
    final currentCount = getClientUnreadCount(clientId);
    _updateClientUnreadCount(
      clientId,
      currentCount + 1,
      clientName: clientName,
    );
  }

  void _resetClientUnreadCount(String clientId) {
    _updateClientUnreadCount(clientId, 0);
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

          // Reset unread count for this client since Shane sent a message
          if (pending.clientId != null) {
            _resetClientUnreadCount(pending.clientId!);
          }
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
                print("message: $m");
                print("attachment: ${m['attachment']}");
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
    if (!isConnected) return;

    _socket?.emitWithAck('messages:mark-read', {
      if (clientId != null) 'clientId': clientId,
      if (messageIds != null) 'messageIds': messageIds,
    });

    // Immediately reset unread count for this client
    if (clientId != null) {
      _resetClientUnreadCount(clientId);
    }
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
    await _clientUnreadCountsSubject.close();
    await _totalUnreadCountSubject.close();
    await _shaneStatusSubject.close();
  }
}
