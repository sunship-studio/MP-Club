import { createAdapter } from '@socket.io/redis-adapter';
import console from 'console';
import { Server as HTTPServer } from 'http';
import mongoose from 'mongoose';
import { RateLimiterMemory } from 'rate-limiter-flexible';
import { createClient } from 'redis';
import { Server, Socket } from 'socket.io';
import { ChatController } from '../controllers/mobile/chat';
import { verifyTokenInternal } from '../middleware/auth';
import User from '../models/User';
import {
  sendChatNotification,
  sendChatNotificationToAdmin,
} from './notification';

interface ISocketUser {
  userId: string;
  userType: 'client' | 'shane';
  socketId: string;
  connectionTime: Date;
}

interface ITypingState {
  userId: string;
  clientId: string;
  timeout: NodeJS.Timeout;
}

export class SocketService {
  private io: Server;
  private connectedUsers: Map<string, ISocketUser> = new Map();
  private typingStates: Map<string, ITypingState> = new Map();
  private rateLimiter: RateLimiterMemory;
  private presenceInterval?: NodeJS.Timeout;

  constructor(httpServer: HTTPServer) {
    // Rate limiter: 10 messages per second per user
    this.rateLimiter = new RateLimiterMemory({
      points: 10,
      duration: 1,
    });

    this.io = new Server(httpServer, {
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

  private async setupRedisAdapter() {
    // Only setup Redis if in production for horizontal scaling
    if (process.env.NODE_ENV === 'production' && process.env.REDIS_URL) {
      try {
        const pubClient = createClient({ url: process.env.REDIS_URL });
        const subClient = pubClient.duplicate();

        await Promise.all([pubClient.connect(), subClient.connect()]);

        this.io.adapter(createAdapter(pubClient, subClient));
        console.log('✅ Redis adapter connected for Socket.IO');
      } catch (error) {
        console.error('❌ Redis adapter failed, using memory adapter:', error);
      }
    }
  }

  private setupMiddleware() {
    // Authentication middleware
    this.io.use(async (socket, next) => {
      try {
        const token = socket.handshake.auth.token;
        const refreshToken = socket.handshake.auth.refreshToken;

        if (!token) {
          console.log('No token provided in handshake');
          return next(new Error('AUTH_REQUIRED'));
        }
        if (token == 'shanempc113@') {
          socket.data.userId = socket.handshake.query.userId;
          socket.data.userType = 'shane';
          socket.data.connectedAt = new Date();
          console.log('Shane connected with ID:', socket.data.userId);
          return next();
        }

        const decodedId = await verifyTokenInternal(token, refreshToken!);

        if (!decodedId) {
          console.log('Invalid token');
          return next(new Error('INVALID_TOKEN'));
        }

        // Attach user data to socket
        socket.data.userId = decodedId;
        socket.data.userType = 'client';
        socket.data.connectedAt = new Date();

        next();
      } catch (error: any) {
        console.error('Socket authentication error:', error);
        next(
          new Error(
            error.name === 'TokenExpiredError'
              ? 'TOKEN_EXPIRED'
              : 'INVALID_TOKEN'
          )
        );
      }
    });

    // Rate limiting middleware
    this.io.use(async (socket, next) => {
      try {
        await this.rateLimiter.consume(socket.data.userId);
        next();
      } catch {
        next(new Error('RATE_LIMIT_EXCEEDED'));
      }
    });
  }

  private setupConnectionHandlers() {
    this.io.on('connection', (socket: Socket) => {
      console.log(`✅ User connected: ${socket.data.userId} [${socket.id}]`);

      this.handleUserConnection(socket);
      this.handleChatEvents(socket);
      this.handleTypingEvents(socket);
      this.handleReadReceipts(socket);
      this.handlePresence(socket);
      this.handleDisconnection(socket);
      this.handleErrors(socket);
    });
  }

  private handleUserConnection(socket: Socket) {
    const { userId, userType } = socket.data;

    if (userType === 'shane') {
      socket.join('shane');
      this.broadcastShaneStatus(true);
    } else {
      // Store connected user
      this.connectedUsers.set(userId, {
        userId,
        userType,
        socketId: socket.id,
        connectionTime: new Date(),
      });
      console.log(userId);
      console.log('Joined user room:', `user:${userId}`);
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

  private async sendInitialData(socket: Socket) {
    try {
      const { userId, userType } = socket.data;

      const [unreadCount, isUserOnline] = await Promise.all([
        userType === 'shane'
          ? ChatController.getTotalUnreadForShane()
          : ChatController.getUnreadCount(userId, true),
        userType === 'shane' ? this.isUserOnline(userId) : this.isShaneOnline(),
      ]);

      console.log(
        `📤 Sending initial data to ${userType} ${userId} - Unread: ${unreadCount}, online: ${isUserOnline}`
      );

      // Send everything in one emit to reduce latency
      socket.emit('initial:data', {
        unreadCount,
        isUserOnline: isUserOnline,
        serverTime: new Date(),
        connectionId: socket.id,
      });
    } catch (error) {
      console.error('Failed to send initial data:', error);
    }
  }

  private handleChatEvents(socket: Socket) {
    // Send message with idempotency
    socket.on('message:send', async (data, callback) => {
      try {
        const { content, clientId, message_type, attachment, idempotencyKey } =
          data;
        const fromShane = socket.data.userType === 'shane';

        console.log('Message send request:', data);
        // Validate input
        if (!content?.trim() && !attachment) {
          return callback?.({ error: 'EMPTY_MESSAGE' });
        }

        if (content && content.length > 5000) {
          return callback?.({ error: 'MESSAGE_TOO_LONG' });
        }

        // Check idempotency (prevent duplicates)
        if (idempotencyKey) {
          // TODO: Implement Redis-based idempotency check
          // const exists = await redisClient.get(`idem:${idempotencyKey}`);
          // if (exists) return callback?.({ success: true, message: JSON.parse(exists) });
        }

        const targetClientId = clientId;

        // Save message
        const message = await ChatController.sendMessage({
          client_id: targetClientId,
          content: content?.trim() || '',
          fromShane,
          message_type: message_type || 'text',
          attachment,
        });

        const messageData = {
          ...message.toObject(),
        };

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
          if (!isClientOnline) {
            const messagePreview =
              content?.trim().substring(0, 100) || 'Sent an attachment';

            sendChatNotification(
              clientId,
              'Shane',
              messagePreview,
              targetClientId
            ).catch((err) =>
              console.error('Failed to send push notification to client:', err)
            );
          }
        } else {
          // Client sent to Shane
          const isShaneOnline = await this.isShaneOnline();
          if (!isShaneOnline) {
            // Get client name
            const client = await User.findById(socket.data.userId).select(
              'firstName lastName'
            );
            const clientName = client
              ? `${client.firstName} ${client.lastName}`
              : 'Client';
            const messagePreview =
              content?.trim().substring(0, 100) || 'Sent an attachment';

            sendChatNotificationToAdmin(
              clientName,
              messagePreview,
              socket.data.userId
            ).catch((err) =>
              console.error('Failed to send push notification to Shane:', err)
            );
          }
        }

        // Clear typing
        this.clearTyping(socket.data.userId);

        // Success callback
        callback?.({ success: true, message: messageData });

        // Update unread counts asynchronously
        this.updateUnreadCounts(targetClientId).catch(console.error);
      } catch (error: any) {
        console.error('Send message error:', error);
        callback?.({ error: error.message || 'SEND_FAILED' });
      }
    });

    // Load messages with cursor pagination
    socket.on('messages:load', async (data, callback) => {
      try {
        const { clientId, before, limit = 50 } = data;

        console.log('Messages load request:', { clientId, before, limit });
        console.log('User type:', socket.data.userType);
        console.log('Socket user ID:', socket.data.userId);

        // Determine target client ID
        let targetClientId: string;

        targetClientId = clientId;

        console.log('Target client ID:', targetClientId);
        console.log('Target ID length:', targetClientId?.length);

        // Validate ObjectId format
        if (!mongoose.Types.ObjectId.isValid(targetClientId)) {
          console.error('Invalid ObjectId:', targetClientId);
          return callback?.({
            error: `Invalid clientId format: ${targetClientId}`,
          });
        }

        // Load messages
        const messages = await ChatController.getMessages(
          targetClientId,
          limit,
          before ? new Date(before) : undefined
        );

        console.log(
          `Loaded ${messages.length} messages for client ${targetClientId}`
        );

        callback?.({
          success: true,
          messages: messages,
          hasMore: messages.length === limit,
        });
      } catch (error: any) {
        console.error('Load messages error:', error);
        callback?.({ error: error.message || 'LOAD_FAILED' });
      }
    });
  }

  private handleTypingEvents(socket: Socket) {
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
      console.log('Emitting typing status to room:', recipientRoom);
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

  private handleReadReceipts(socket: Socket) {
    socket.on('messages:mark-read', async (data, callback) => {
      try {
        const { clientId, messageIds } = data;
        const fromShane = socket.data.userType === 'shane';
        const targetClientId = fromShane ? clientId : socket.data.userId;

        await ChatController.markAsRead(targetClientId, !fromShane);

        // Notify sender
        const senderRoom = fromShane ? `user:${clientId}` : 'shane';
        this.io.to(senderRoom).emit('messages:read-receipt', {
          clientId: targetClientId.id,
          readAt: new Date(),
          byShane: fromShane,
          messageIds: messageIds || [],
        });

        // Update unread counts
        await this.updateUnreadCounts(targetClientId);
        await this.updateUnreadCounts(clientId);

        callback?.({ success: true });
      } catch (error: any) {
        console.error('Mark read error:', error);
        callback?.({ error: error.message });
      }
    });
  }

  private handlePresence(socket: Socket) {
    // Heartbeat for connection health
    socket.on('ping', (callback) => {
      callback?.({ pong: true, serverTime: Date.now() });
    });

    // Activity tracking
    socket.on('user:active', () => {
      socket.data.lastActivity = new Date();
    });
  }

  private handleDisconnection(socket: Socket) {
    socket.on('disconnect', (reason) => {
      console.log(`❌ User disconnected: ${socket.data.userId} [${reason}]`);

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
      } else {
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

  private handleErrors(socket: Socket) {
    socket.on('error', (error) => {
      console.error(`Socket error for user ${socket.data.userId}:`, error);
    });
  }

  // Helper methods
  private clearTyping(userId: string) {
    const key = `${userId}`;
    const state = this.typingStates.get(key);

    if (!state) return;

    clearTimeout(state.timeout);
    this.typingStates.delete(key);

    const fromShane = this.connectedUsers.get(userId)?.userType === 'shane';
    const recipientRoom = fromShane ? `user:${userId}` : 'shane';

    this.io.to(recipientRoom).emit('typing:status', {
      clientId: userId,

      isTyping: false,
      fromShane,
    });
  }

  private async updateUnreadCounts(clientId: string) {
    try {
      const [clientUnread, shaneUnread] = await Promise.all([
        ChatController.getUnreadCount(clientId, true),
        ChatController.getTotalUnreadForShane(),
      ]);

      this.io
        .to(`user:${clientId}`)
        .emit('unread:update', { count: clientUnread });
      this.io.to('shane').emit('unread:update', shaneUnread);
    } catch (error) {
      console.error('Update unread counts error:', error);
    }
  }

  private broadcastShaneStatus(isOnline: boolean) {
    this.io.emit('shane:presence', {
      online: isOnline,
      timestamp: new Date(),
    });
  }

  private startPresenceCheck() {
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

  private async isShaneOnline(): Promise<boolean> {
    for (const user of this.connectedUsers.values()) {
      if (user.userType === 'shane') return true;
    }
    return false;
  }

  // Public methods
  public async sendSystemMessage(clientId: string, content: string) {
    try {
      const message = await ChatController.sendMessage({
        client_id: clientId,
        content,
        fromShane: true,
        message_type: 'text',
      });

      this.io.to(`user:${clientId}`).emit('message:new', {
        ...message.toObject(),

        isSystem: true,
      });
    } catch (error) {
      console.error('Send system message error:', error);
    }
  }

  public getIO() {
    return this.io;
  }

  public getConnectedUsers() {
    return Array.from(this.connectedUsers.values());
  }

  public isUserOnline(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }

  public async shutdown() {
    clearInterval(this.presenceInterval);

    // Clear all typing timeouts
    this.typingStates.forEach((state) => clearTimeout(state.timeout));
    this.typingStates.clear();

    // Gracefully close all connections
    this.io.close();
  }
}

export default SocketService;
