import mongoose from "mongoose";
import ChatRoom from "../models/ChatRoom";
import Message from "../models/Message";
import User, { IUser } from "../models/User";

export class ChatService {
  async getShaneConversation() {
    const chatRooms = await ChatRoom.find({});
    return chatRooms;
  }
  static async sendMessage(data: {
    client_id: string;
    content: string;
    fromShane: boolean;
    message_type?: string;
    attachment?: any;
  }) {
    const message = new Message(data);
    await message.save();

    // Update conversation
    await this.updateChatRoom(data.client_id, message);

    return message;
  }

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
          },
        },
      },
      { new: true, upsert: true }
    );
  }

  static async markRead(clientId: string, fromShane: boolean) {
    return Message.updateMany(
      {
        client_id: new mongoose.Types.ObjectId(clientId),
        fromShane: fromShane,
      },
      {
        $set: {
          status: {
            read: new Date(),
          },
        },
      }
    );
  }

  static async getMessages(clientId: string, limit = 20, offset = 0) {
    return Message.find({ clientId: clientId })
      .sort({ timestamp: -1 })
      .skip(offset)
      .limit(limit);
  }
  static async getUnreadCount(clientId: string) {
    return Message.countDocuments({
      clientId: new mongoose.Types.ObjectId(clientId),
      fromShane: true,
      "status.read": { $exists: false },
    });
  }
}
