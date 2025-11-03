import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/di/injection.dart';
import 'package:mpc_mobile_app/core/network/dio.dart';
import 'package:mpc_mobile_app/core/storage/token.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/message.dart';
import 'package:mpc_mobile_app/data/models/user.dart';
import 'package:mpc_mobile_app/main.dart';
import 'package:mpc_mobile_app/presentation/widgets/chat/divider.dart';
import 'package:mpc_mobile_app/presentation/widgets/chat/header.dart';
import 'package:mpc_mobile_app/presentation/widgets/chat/message.dart';
import 'package:mpc_mobile_app/presentation/widgets/check_in/sheets/browse_file.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/notification_service.dart';
import 'package:mpc_mobile_app/services/socket.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdmin; // true for Shane's app, false for client app
  final User user;
  const ChatScreen({super.key, required this.user, this.isAdmin = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final SocketService _socketService = getIt<SocketService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _isOnline = false;
  String _lastSeenText = "Offline";
  bool _isLoadingMessages = false;
  bool _hasMoreMessages = true;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  File? selectedFile;
  bool isUploadingImage = false;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _readReceiptSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _presenceSubscription;

  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeChat();
    _setupListeners();
    _scrollController.addListener(_onScroll);

    // Set navigation context for NotificationService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navBarKey.currentState?.turnOffNavBar();
      getIt<NotificationService>().setNavigationContext(context);
    });
  }

  ///
  /// SET SELECTED FILE
  ///
  void _setSelectedFile(File file) {
    setState(() {
      selectedFile = file;
    });
  }

  ///
  /// INITIALIZE CHAT
  ///

  void _initializeChat() async {
    final token = await getIt<TokenStorage>().getAccessToken() ?? '';
    final refreshToken = await getIt<TokenStorage>().getRefreshToken() ?? '';
    await _socketService.connect(
      debugMode
          ? 'http://172.20.10.12:3500'
          : 'wss://mp-club-production.up.railway.app',
      token,
      refreshToken,
    );
  }

  ///
  // SETUP LISTENERS
  ///

  void _setupListeners() {
    _connectionSubscription = _socketService.connectionStream.listen((status) {
      setState(() => _connectionStatus = status);
      if (status == ConnectionStatus.connected) {
        _loadMessages();
        _markMessagesAsRead();
      }
    });

    _messageSubscription = _socketService.messageStream.listen((message) {
      setState(() {
        _messages.insert(0, message);
      });

      if (message.fromShane) {
        _markMessagesAsRead();
      }

      _scrollToBottom();
    });

    _typingSubscription = _socketService.typingStream.listen((indicator) {
      bool shouldShow =
          widget.isAdmin ? (!indicator.fromShane) : indicator.fromShane;

      if (shouldShow) {
        setState(() => _isTyping = indicator.isTyping);
      }
    });

    _readReceiptSubscription = _socketService.readReceiptStream.listen((
      receipt,
    ) {
      setState(() {
        for (var message in _messages) {
          bool isMyMessage =
              widget.isAdmin ? message.fromShane : !message.fromShane;
          if (isMyMessage && message.status.read == null) {
            message.status.read = receipt.readAt;
          }
        }
      });
    });

    _presenceSubscription = _socketService.shaneStatusStream.listen((isOnline) {
      setState(() {
        _isOnline = isOnline;
        _lastSeenText = isOnline ? "Online" : "Offline";
      });
    });
  }

  ///
  // LOAD MESSAGES
  ///

  Future<void> _loadMessages({DateTime? before}) async {
    if (_isLoadingMessages || !_hasMoreMessages) return;

    setState(() => _isLoadingMessages = true);
    try {
      final messages = await _socketService.loadMessages(
        clientId: widget.user.id.toString(),
        before:
            before ?? (_messages.isNotEmpty ? _messages.last.timestamp : null),
      );

      setState(() {
        if (before == null) {
          _messages.clear();
        }
        _messages.addAll(messages);
        _hasMoreMessages = messages.length >= 50;
      });

      if (before == null) {
        _scrollToBottom();
      }
    } catch (e) {
      _showError('Failed to load messages: $e');
    } finally {
      setState(() => _isLoadingMessages = false);
    }
  }

  ///
  /// SCROLL HANDLER
  ///

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      if (_messages.isNotEmpty) {
        _loadMessages(before: _messages.last.timestamp);
      }
    }
  }

  ///
  /// SCROLL TO BOTTOM
  ///

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  ///
  /// SEND VOICE MESSAGE
  ///

  ///
  /// SEND IMAGE MESSAGE
  ///
  Future<void> _sendImageMessage() async {
    setState(() {
      isUploadingImage = true;
    });
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (selectedFile == null) return;
    final response = await getIt<DioClient>().postFormData(
      endpoint: '/chat/upload-image',
      formData: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          selectedFile!.path,
          filename: selectedFile!.path.split('/').last,
        ),
      }),
    );
    String? imageUrl;
    response.data = response.data['data'];
    if (response.statusCode != 200) {
      _showError('Failed to upload image');
      return;
    } else {
      print("Setting image URL from response: ${response.data['url']}");
      imageUrl = response.data['url'];
    }

    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: widget.user.id,
      content: text,
      fromShane: widget.isAdmin,
      attachment: {
        'type': 'image',
        'url': imageUrl,
        'name': response.data['name'],
        'size': response.data['size'],
      },
      timestamp: DateTime.now(),
      status: MessageStatus(delivered: DateTime.now()),
    );

    setState(() {
      isUploadingImage = false;
      _messages.insert(0, tempMessage);
      _messageController.clear();
      selectedFile = null;
    });
    _scrollToBottom();
    _socketService.stopTyping(clientId: widget.isAdmin ? widget.user.id : null);

    try {
      await _socketService.sendMessage(
        content: text,
        clientId: widget.user.id,
        attachment: {
          'type': 'image',
          'url': imageUrl,
          'name': response.data['name'],
          'size': response.data['size'],
        },
      );
    } catch (e) {
      debugPrint('Error sending image message: $e');
      _showError('Failed to send image: $e');
      setState(() {
        _messages.removeWhere((m) => m.id == tempMessage.id);
      });
    }
  }

  ///
  /// SEND MESSAGE
  ///

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (_messageController.text.isEmpty) return;

    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: widget.user.id,
      content: _messageController.text,
      fromShane: widget.isAdmin,

      timestamp: DateTime.now(),
      status: MessageStatus(delivered: DateTime.now()),
    );

    setState(() {
      _messages.insert(0, tempMessage);
      _messageController.clear();
    });

    _scrollToBottom();
    _socketService.stopTyping(clientId: widget.isAdmin ? widget.user.id : null);

    try {
      await _socketService.sendMessage(content: text, clientId: widget.user.id);
    } catch (e) {
      _showError('Failed to send: $e');
      setState(() {
        _messages.removeWhere((m) => m.id == tempMessage.id);
      });
    }
  }

  ///
  /// TEXT CHANGE HANDLER
  ///

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      _typingDebounce?.cancel();
      _socketService.startTyping(clientId: widget.user.id);

      _typingDebounce = Timer(const Duration(milliseconds: 1000), () {
        _socketService.stopTyping(clientId: widget.user.id);
      });
    } else {
      _socketService.stopTyping(clientId: widget.user.id);
    }
  }

  ///
  /// MARK MESSAGES AS READ
  ///

  Future<void> _markMessagesAsRead() async {
    await _socketService.markMessagesAsRead(clientId: widget.user.id);
  }

  ///
  /// SHOW ERROR
  ///

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ChatScreenHeader(
            buildConnectionIndicator: _buildConnectionIndicator,
            isOnline: _isOnline,
            lastSeenText: _lastSeenText,
          ),
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color color;
    IconData icon;

    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        color = Colors.orange;
        icon = Icons.sync;
        break;
      case ConnectionStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.cloud_off;
    }

    return Icon(icon, color: color, size: 16.w);
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty && _isLoadingMessages) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.w,
        vertical: 10.h,
      ),
      itemCount: _messages.length + (_isTyping ? 1 : 0) + 1,
      itemBuilder: (context, index) {
        if (index == _messages.length + (_isTyping ? 1 : 0)) {
          return DayDivider();
        }

        if (index == 0 && _isTyping) {
          return _buildTypingIndicator();
        }

        final messageIndex = _isTyping ? index - 1 : index;
        final message = _messages[messageIndex];

        return ChatMessage(
          isNextMessageFromSameSender:
              messageIndex < _messages.length - 1
                  ? (widget.isAdmin
                      ? _messages[messageIndex + 1].fromShane ==
                          message.fromShane
                      : !_messages[messageIndex + 1].fromShane ==
                          !message.fromShane)
                  : false,
          attachment: message.attachment,
          content: message.content,
          isSentByMe: widget.isAdmin ? message.fromShane : !message.fromShane,
          status: _getMessageStatus(message),
          time: _formatTime(message.timestamp),
          replyTo: null,
        );
      },
    );
  }

  String _getMessageStatus(Message message) {
    if (message.status.read != null) return "read";
    if (message.status.delivered != null) return "delivered";
    return "sent";
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 4.w),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,

          padding: EdgeInsets.all(8.w),
          margin: EdgeInsets.only(bottom: 8.h),
          decoration: BoxDecoration(
            color: AppColors.lightCardColor2.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        fit: BoxFit.cover,
                        selectedFile!.path,

                        height: 60.w,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        selectedFile!.path.split('/').last,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploadingImage)
                Container(
                  width: 20.w,
                  height: 20.w,
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  child: CircularProgressIndicator(color: AppColors.blueColor),
                ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFile = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 20.w,
                  color: AppColors.darkTextColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding.w,
        right: horizontalPadding.w,
        bottom: 30.h,
        top: 10.h,
      ),
      color: Colors.white,
      child: Column(
        children: [
          if (selectedFile != null) ...[
            _buildImagePreview(),
            SizedBox(height: 8.h),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  onChanged: _onTextChanged,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkTextColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                    border: InputBorder.none,
                    hintText: "Type a message...",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkTextColor.withValues(alpha: 0.5),
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              Gap(8.w),
              GestureDetector(
                onTap: () {
                  if (selectedFile != null) {
                    _sendImageMessage();
                  } else {
                    _sendMessage();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    CupertinoIcons.paperplane,
                    size: 20.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  File? selectedFile = await showBrowseFileSheet(context);
                  if (selectedFile != null) {
                    _setSelectedFile(selectedFile);
                  }

                  print("Selected file: $selectedFile");
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    CupertinoIcons.camera,
                    size: 20.w,
                    color: AppColors.darkTextColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Gap(12.w),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    margin: EdgeInsets.only(left: 6.w),
                    child: Icon(
                      CupertinoIcons.mic,
                      size: 24.w,
                      color: AppColors.darkTextColor.withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkScaffoldColor.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Center(
                        child: Text(
                          "Soon",
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(12.w),
              GestureDetector(
                onTap: () {
                  context.push('/check_in/submit');
                },
                child: Text(
                  "Submit check-in 📝",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueColor.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _connectionSubscription?.cancel();
    _presenceSubscription?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navBarKey.currentState?.turnOnNavBar();
    });
    super.dispose();
  }
}
