"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SocketService = void 0;
const redis_adapter_1 = require("@socket.io/redis-adapter");
const console_1 = __importDefault(require("console"));
const mongoose_1 = __importDefault(require("mongoose"));
const rate_limiter_flexible_1 = require("rate-limiter-flexible");
const redis_1 = require("redis");
const socket_io_1 = require("socket.io");
const chat_1 = require("../controllers/mobile/chat");
const auth_1 = require("../middleware/auth");
const User_1 = __importDefault(require("../models/User"));
const notification_1 = require("./notification");
class SocketService {
    constructor(httpServer) {
        this.connectedUsers = new Map();
        this.typingStates = new Map();
        // Rate limiter: 10 messages per second per user
        this.rateLimiter = new rate_limiter_flexible_1.RateLimiterMemory({
            points: 10,
            duration: 1,
        });
        this.io = new socket_io_1.Server(httpServer, {
            cors: {
                origin: process.env.FRONTEND_URL || '*',
                methods: ['GET', 'POST'],
                credentials: true,
            },
            pingTimeout: 60000,
            pingInterval: 25000,
            transports: ['websocket', 'polling'],
            // Enable compression for better performance
            perMessageDeflate: {
                threshold: 1024,
            },
            // Connection state recovery (new in Socket.IO v4)
            connectionStateRecovery: {
                maxDisconnectionDuration: 2 * 60 * 1000, // 2 minutes
                skipMiddlewares: true,
            },
        });
        this.setupRedisAdapter();
        this.setupMiddleware();
        this.setupConnectionHandlers();
        this.startPresenceCheck();
    }
    setupRedisAdapter() {
        return __awaiter(this, void 0, void 0, function* () {
            // Only setup Redis if in production for horizontal scaling
            if (process.env.NODE_ENV === 'production' && process.env.REDIS_URL) {
                try {
                    const pubClient = (0, redis_1.createClient)({ url: process.env.REDIS_URL });
                    const subClient = pubClient.duplicate();
                    yield Promise.all([pubClient.connect(), subClient.connect()]);
                    this.io.adapter((0, redis_adapter_1.createAdapter)(pubClient, subClient));
                    console_1.default.log('✅ Redis adapter connected for Socket.IO');
                }
                catch (error) {
                    console_1.default.error('❌ Redis adapter failed, using memory adapter:', error);
                }
            }
        });
    }
    setupMiddleware() {
        // Authentication middleware
        this.io.use((socket, next) => __awaiter(this, void 0, void 0, function* () {
            try {
                const token = socket.handshake.auth.token;
                const refreshToken = socket.handshake.auth.refreshToken;
                if (!token) {
                    console_1.default.log('No token provided in handshake');
                    return next(new Error('AUTH_REQUIRED'));
                }
                if (token == 'shanempc113@') {
                    socket.data.userId = socket.handshake.query.userId;
                    socket.data.userType = 'shane';
                    socket.data.connectedAt = new Date();
                    console_1.default.log('Shane connected with ID:', socket.data.userId);
                    return next();
                }
                const decodedId = yield (0, auth_1.verifyTokenInternal)(token, refreshToken);
                if (!decodedId) {
                    console_1.default.log('Invalid token');
                    return next(new Error('INVALID_TOKEN'));
                }
                // Attach user data to socket
                socket.data.userId = decodedId;
                socket.data.userType = 'client';
                socket.data.connectedAt = new Date();
                next();
            }
            catch (error) {
                console_1.default.error('Socket authentication error:', error);
                next(new Error(error.name === 'TokenExpiredError'
                    ? 'TOKEN_EXPIRED'
                    : 'INVALID_TOKEN'));
            }
        }));
        // Rate limiting middleware
        this.io.use((socket, next) => __awaiter(this, void 0, void 0, function* () {
            try {
                yield this.rateLimiter.consume(socket.data.userId);
                next();
            }
            catch (_a) {
                next(new Error('RATE_LIMIT_EXCEEDED'));
            }
        }));
    }
    setupConnectionHandlers() {
        this.io.on('connection', (socket) => {
            console_1.default.log(`✅ User connected: ${socket.data.userId} [${socket.id}]`);
            this.handleUserConnection(socket);
            this.handleChatEvents(socket);
            this.handleTypingEvents(socket);
            this.handleReadReceipts(socket);
            this.handlePresence(socket);
            this.handleDisconnection(socket);
            this.handleErrors(socket);
        });
    }
    handleUserConnection(socket) {
        const { userId, userType } = socket.data;
        console_1.default.log('Handling connection for user:', userId);
        if (userType === 'shane') {
            socket.join('shane');
            this.broadcastShaneStatus(true);
        }
        else {
            // Store connected user
            this.connectedUsers.set(userId, {
                userId,
                userType,
                socketId: socket.id,
                connectionTime: new Date(),
            });
            console_1.default.log(userId);
            console_1.default.log('Joined user room:', `user:${userId}`);
            // Join rooms
            socket.join(`user:${userId.id}`);
            // Notify Shane of client connection
            this.io.to('shane').emit('client:presence', {
                clientId: userId,
                status: 'online',
                timestamp: new Date(),
            });
        }
        // Send initial data bundle (reduce round trips)
        this.sendInitialData(socket);
    }
    sendInitialData(socket) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { userId, userType } = socket.data;
                const [unreadCount, isUserOnline] = yield Promise.all([
                    userType === 'shane'
                        ? chat_1.ChatController.getTotalUnreadForShane()
                        : chat_1.ChatController.getUnreadCount(userId, true),
                    userType === 'shane' ? this.isUserOnline(userId) : this.isShaneOnline(),
                ]);
                console_1.default.log(`📤 Sending initial data to ${userType} ${userId} - Unread: ${unreadCount}, online: ${isUserOnline}`);
                // Send everything in one emit to reduce latency
                socket.emit('initial:data', {
                    unreadCount,
                    isUserOnline: isUserOnline,
                    serverTime: new Date(),
                    connectionId: socket.id,
                });
            }
            catch (error) {
                console_1.default.error('Failed to send initial data:', error);
            }
        });
    }
    handleChatEvents(socket) {
        // Send message with idempotency
        socket.on('message:send', (data, callback) => __awaiter(this, void 0, void 0, function* () {
            console_1.default.log('Sending message event data:', data);
            try {
                const { content, clientId, message_type, attachment, idempotencyKey } = data;
                const fromShane = socket.data.userType === 'shane';
                console_1.default.log('Message send request:', data);
                // Validate input
                if (!(content === null || content === void 0 ? void 0 : content.trim()) && !attachment) {
                    return callback === null || callback === void 0 ? void 0 : callback({ error: 'EMPTY_MESSAGE' });
                }
                if (content && content.length > 5000) {
                    return callback === null || callback === void 0 ? void 0 : callback({ error: 'MESSAGE_TOO_LONG' });
                }
                // Check idempotency (prevent duplicates)
                if (idempotencyKey) {
                    // TODO: Implement Redis-based idempotency check
                    // const exists = await redisClient.get(`idem:${idempotencyKey}`);
                    // if (exists) return callback?.({ success: true, message: JSON.parse(exists) });
                }
                const targetClientId = clientId;
                // Save message
                const message = yield chat_1.ChatController.sendMessage({
                    client_id: targetClientId,
                    content: (content === null || content === void 0 ? void 0 : content.trim()) || '',
                    fromShane,
                    message_type: message_type || 'text',
                    attachment,
                });
                const messageData = Object.assign({}, message.toObject());
                // Store in idempotency cache
                if (idempotencyKey) {
                    // await redisClient.setex(`idem:${idempotencyKey}`, 300, JSON.stringify(messageData));
                }
                // Emit to recipient
                const recipientRoom = fromShane ? `user:${clientId}` : 'shane';
                this.io.to(recipientRoom).emit('message:new', messageData);
                // Send push notification if recipient is offline
                if (fromShane) {
                    // Shane sent to client
                    const isClientOnline = this.isUserOnline(clientId);
                    console_1.default.log('Emitting push notification to client:', clientId);
                    if (!isClientOnline) {
                        const messagePreview = (content === null || content === void 0 ? void 0 : content.trim().substring(0, 100)) || 'Sent an attachment';
                        (0, notification_1.sendChatNotification)(clientId, 'Shane', messagePreview, targetClientId).catch((err) => console_1.default.error('Failed to send push notification to client:', err));
                    }
                }
                else {
                    // Client sent to Shane
                    const isShaneOnline = yield this.isShaneOnline();
                    if (!isShaneOnline) {
                        // Get client name
                        const client = yield User_1.default.findById(socket.data.userId).select('firstName lastName');
                        const clientName = client
                            ? `${client.firstName} ${client.lastName}`
                            : 'Client';
                        const messagePreview = (content === null || content === void 0 ? void 0 : content.trim().substring(0, 100)) || 'Sent an attachment';
                        (0, notification_1.sendChatNotificationToAdmin)(clientName, messagePreview, socket.data.userId).catch((err) => console_1.default.error('Failed to send push notification to Shane:', err));
                    }
                }
                // Clear typing
                this.clearTyping(socket.data.userId);
                // Success callback
                callback === null || callback === void 0 ? void 0 : callback({ success: true, message: messageData });
                // Update unread counts asynchronously
                this.updateUnreadCounts(targetClientId).catch(console_1.default.error);
            }
            catch (error) {
                console_1.default.error('Send message error:', error);
                callback === null || callback === void 0 ? void 0 : callback({ error: error.message || 'SEND_FAILED' });
            }
        }));
        // Load messages with cursor pagination
        socket.on('messages:load', (data, callback) => __awaiter(this, void 0, void 0, function* () {
            try {
                const { clientId, before, limit = 50 } = data;
                console_1.default.log('Messages load request:', { clientId, before, limit });
                console_1.default.log('User type:', socket.data.userType);
                console_1.default.log('Socket user ID:', socket.data.userId);
                // Determine target client ID
                let targetClientId;
                targetClientId = clientId;
                console_1.default.log('Target client ID:', targetClientId);
                console_1.default.log('Target ID length:', targetClientId === null || targetClientId === void 0 ? void 0 : targetClientId.length);
                // Validate ObjectId format
                if (!mongoose_1.default.Types.ObjectId.isValid(targetClientId)) {
                    console_1.default.error('Invalid ObjectId:', targetClientId);
                    return callback === null || callback === void 0 ? void 0 : callback({
                        error: `Invalid clientId format: ${targetClientId}`,
                    });
                }
                // Load messages
                const messages = yield chat_1.ChatController.getMessages(targetClientId, limit, before ? new Date(before) : undefined);
                console_1.default.log(`Loaded ${messages.length} messages for client ${targetClientId}`);
                callback === null || callback === void 0 ? void 0 : callback({
                    success: true,
                    messages: messages,
                    hasMore: messages.length === limit,
                });
            }
            catch (error) {
                console_1.default.error('Load messages error:', error);
                callback === null || callback === void 0 ? void 0 : callback({ error: error.message || 'LOAD_FAILED' });
            }
        }));
    }
    handleTypingEvents(socket) {
        socket.on('typing:start', (data) => {
            const { clientId } = data;
            const fromShane = socket.data.userType === 'shane';
            const key = `${clientId}`;
            // Clear existing timeout
            const existing = this.typingStates.get(key);
            if (existing) {
                clearTimeout(existing.timeout);
            }
            // Broadcast typing indicator
            const recipientRoom = fromShane ? `user:${clientId}` : 'shane';
            console_1.default.log('Emitting typing status to room:', recipientRoom);
            this.io.to(recipientRoom).emit('typing:status', {
                clientId: clientId,
                isTyping: true,
                fromShane,
            });
            // Auto-clear after 3 seconds
            const timeout = setTimeout(() => {
                this.clearTyping(socket.data.userId);
            }, 3000);
            this.typingStates.set(key, {
                userId: socket.data.userId,
                clientId: clientId,
                timeout,
            });
        });
        socket.on('typing:stop', (data) => {
            const { clientId } = data;
            const fromShane = socket.data.userType === 'shane';
            const targetClientId = fromShane ? clientId : socket.data.userId;
            this.clearTyping(socket.data.userId);
        });
    }
    handleReadReceipts(socket) {
        socket.on('messages:mark-read', (data, callback) => __awaiter(this, void 0, void 0, function* () {
            try {
                const { clientId, messageIds } = data;
                const fromShane = socket.data.userType === 'shane';
                const targetClientId = fromShane ? clientId : socket.data.userId;
                yield chat_1.ChatController.markAsRead(targetClientId, !fromShane);
                // Notify sender
                const senderRoom = fromShane ? `user:${clientId}` : 'shane';
                this.io.to(senderRoom).emit('messages:read-receipt', {
                    clientId: targetClientId.id,
                    readAt: new Date(),
                    byShane: fromShane,
                    messageIds: messageIds || [],
                });
                // Update unread counts
                yield this.updateUnreadCounts(targetClientId);
                yield this.updateUnreadCounts(clientId);
                callback === null || callback === void 0 ? void 0 : callback({ success: true });
            }
            catch (error) {
                console_1.default.error('Mark read error:', error);
                callback === null || callback === void 0 ? void 0 : callback({ error: error.message });
            }
        }));
    }
    handlePresence(socket) {
        // Heartbeat for connection health
        socket.on('ping', (callback) => {
            callback === null || callback === void 0 ? void 0 : callback({ pong: true, serverTime: Date.now() });
        });
        // Activity tracking
        socket.on('user:active', () => {
            socket.data.lastActivity = new Date();
        });
    }
    handleDisconnection(socket) {
        socket.on('disconnect', (reason) => {
            console_1.default.log(`❌ User disconnected: ${socket.data.userId} [${reason}]`);
            const { userId, userType } = socket.data;
            // Remove from tracking
            this.connectedUsers.delete(userId);
            // Clear typing states
            this.typingStates.forEach((state, key) => {
                if (key.startsWith(`${userId}:`)) {
                    clearTimeout(state.timeout);
                    this.typingStates.delete(key);
                }
            });
            // Notify about offline status
            if (userType === 'shane') {
                this.broadcastShaneStatus(false);
            }
            else {
                this.io.to('shane').emit('client:presence', {
                    clientId: userId,
                    status: 'offline',
                    timestamp: new Date(),
                });
            }
        });
        socket.on('disconnecting', () => {
            // Cleanup before full disconnect
            socket.data.disconnecting = true;
        });
    }
    handleErrors(socket) {
        socket.on('error', (error) => {
            console_1.default.error(`Socket error for user ${socket.data.userId}:`, error);
        });
    }
    // Helper methods
    clearTyping(userId) {
        var _a;
        const key = `${userId}`;
        const state = this.typingStates.get(key);
        if (!state)
            return;
        clearTimeout(state.timeout);
        this.typingStates.delete(key);
        const fromShane = ((_a = this.connectedUsers.get(userId)) === null || _a === void 0 ? void 0 : _a.userType) === 'shane';
        const recipientRoom = fromShane ? `user:${userId}` : 'shane';
        this.io.to(recipientRoom).emit('typing:status', {
            clientId: userId,
            isTyping: false,
            fromShane,
        });
    }
    updateUnreadCounts(clientId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const [clientUnread, shaneUnread] = yield Promise.all([
                    chat_1.ChatController.getUnreadCount(clientId, true),
                    chat_1.ChatController.getTotalUnreadForShane(),
                ]);
                this.io
                    .to(`user:${clientId}`)
                    .emit('unread:update', { count: clientUnread });
                this.io.to('shane').emit('unread:update', shaneUnread);
            }
            catch (error) {
                console_1.default.error('Update unread counts error:', error);
            }
        });
    }
    broadcastShaneStatus(isOnline) {
        this.io.emit('shane:presence', {
            online: isOnline,
            timestamp: new Date(),
        });
    }
    startPresenceCheck() {
        // Check for stale connections every 30 seconds
        this.presenceInterval = setInterval(() => {
            const now = Date.now();
            this.connectedUsers.forEach((user, userId) => {
                const socket = this.io.sockets.sockets.get(user.socketId);
                if (!socket || !socket.connected) {
                    this.connectedUsers.delete(userId);
                }
            });
        }, 30000);
    }
    isShaneOnline() {
        return __awaiter(this, void 0, void 0, function* () {
            for (const user of this.connectedUsers.values()) {
                if (user.userType === 'shane')
                    return true;
            }
            return false;
        });
    }
    // Public methods
    sendSystemMessage(clientId, content) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const message = yield chat_1.ChatController.sendMessage({
                    client_id: clientId,
                    content,
                    fromShane: true,
                    message_type: 'text',
                });
                this.io.to(`user:${clientId}`).emit('message:new', Object.assign(Object.assign({}, message.toObject()), { isSystem: true }));
            }
            catch (error) {
                console_1.default.error('Send system message error:', error);
            }
        });
    }
    getIO() {
        return this.io;
    }
    getConnectedUsers() {
        return Array.from(this.connectedUsers.values());
    }
    isUserOnline(userId) {
        return this.connectedUsers.has(userId);
    }
    shutdown() {
        return __awaiter(this, void 0, void 0, function* () {
            clearInterval(this.presenceInterval);
            // Clear all typing timeouts
            this.typingStates.forEach((state) => clearTimeout(state.timeout));
            this.typingStates.clear();
            // Gracefully close all connections
            this.io.close();
        });
    }
}
exports.SocketService = SocketService;
exports.default = SocketService;
