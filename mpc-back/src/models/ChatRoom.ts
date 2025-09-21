export interface IChatRoom extends Document {
  clientId: string;
  createdAt: Date;
  updatedAt: Date;
  lastMessageAt: Date;
  lastMessageContent: string;
  unreadCount: number;
}
import mongoose, { Schema } from "mongoose";

const ChatRoomSchema = new Schema<IChatRoom>({
  clientId: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  lastMessageAt: { type: Date, default: Date.now },
  lastMessageContent: { type: String, default: "" },
  unreadCount: { type: Number, default: 0 },
});

const ChatRoom = mongoose.model<IChatRoom>("ChatRoom", ChatRoomSchema);
export default ChatRoom;
