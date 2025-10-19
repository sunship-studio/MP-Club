import mongoose from "mongoose";
import { uploadToCloudinary } from "../../config/cloudinary";
import ChatRoom from "../../models/ChatRoom";
import Message from "../../models/Message";

export class ChatController {


  // Get specific chat room
  static async getChatRoom(clientId: string) {
    return ChatRoom.findOne({
      clientId: new mongoose.Types.ObjectId(clientId),
    }).populate("clientId", "name email avatar");
  }

  // Send a message
  static async sendMessage(data: {
    client_id: string;
    content: string;
    fromShane: boolean;
    message_type?: "text" | "image" | "file" | "audio";
    attachment?: {
      url: string;
      type: string;
      name?: string;
      size?: number;
    };
  }) {
    const now = new Date();
    const message = new Message({
      ...data,
      timestamp: now,
      status: {
        delivered: now,
      },
    });
    await message.save();

    // Update chat room
    await this.updateChatRoom(data.client_id, message);

    return message;
  }
  // Upload Image
  static async uploadImage(fileBuffer: Buffer, fileName: string, mimeType: string) {

    const uploadResult = await uploadToCloudinary(fileBuffer, fileName);
    console.log('Upload Result:', uploadResult);

    return {
      url: uploadResult.url,
      type: mimeType,
      name: fileName,
      size: fileBuffer.length,
    };
  }
  // Update chat room with last message
  static async updateChatRoom(clientId: string, message: any) {
    return ChatRoom.findOneAndUpdate(
      { clientId: new mongoose.Types.ObjectId(clientId) },
      {
        $set: {
          last_message_at: message.timestamp,
          last_message: {
            content: message.content,
            fromShane: message.fromShane,
            timestamp: message.timestamp,
            message_type: message.message_type,
          },
        },
        $inc: {
          [`unread_count.${message.fromShane ? "client" : "shane"}`]: 1,
        },
      },
      { new: true, upsert: true }
    );
  }

  // Mark messages as read
  static async markAsRead(clientId: string, fromShane: boolean) {
    const result = await Message.updateMany(
      {
        client_id: new mongoose.Types.ObjectId(clientId),
        fromShane: fromShane,
        "status.read": { $exists: false },
      },
      {
        $set: {
          "status.read": new Date(),
        },
      }
    );

    // Reset unread count
    await ChatRoom.updateOne(
      { clientId: new mongoose.Types.ObjectId(clientId) },
      {
        $set: {
          [`unread_count.${fromShane ? "client" : "shane"}`]: 0,
        },
      }
    );

    return result;
  }

  // Mark message as delivered
  static async markAsDelivered(messageId: string) {
    return Message.findByIdAndUpdate(
      messageId,
      {
        $set: {
          "status.delivered": new Date(),
        },
      },
      { new: true }
    );
  }

  // Get messages with pagination
  static async getMessages(clientId: string, limit = 50, before?: Date) {
    const query: any = {
      client_id: new mongoose.Types.ObjectId(clientId),
    };

    if (before) {
      query.timestamp = { $lt: before };
    }

    return Message.find(query).sort({ timestamp: -1 }).limit(limit).lean();
  }

  // Get unread count
  static async getUnreadCount(clientId: string, forShane: boolean) {
    return Message.countDocuments({
      client_id: new mongoose.Types.ObjectId(clientId),
      fromShane: forShane,
      "status.read": { $exists: false },
    });
  }

  // Get total unread count for Shane (across all clients)
  static async getTotalUnreadForShane() {
    const result = await Message.aggregate([
      {
        $match: {
          fromShane: false,
          "status.read": { $exists: false },
        },
      },
      {
        $group: {
          _id: "$client_id",
          count: { $sum: 1 },
        },
      },
    ]);

    return {
      total: result.reduce((sum, item) => sum + item.count, 0),
      byClient: result,
    };
  }

  // Create or get chat room
  static async getOrCreateChatRoom(clientId: string) {
    let chatRoom = await this.getChatRoom(clientId);

    if (!chatRoom) {
      chatRoom = await ChatRoom.create({
        clientId: new mongoose.Types.ObjectId(clientId),
        created_at: new Date(),
        unread_count: {
          shane: 0,
          client: 0,
        },
      });
    }

    return chatRoom;
  }
}
