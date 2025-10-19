// src/models/Message.ts
import mongoose, { Document, Schema } from 'mongoose';

export interface IMessage extends Document {
  client_id: mongoose.Types.ObjectId;
  content: string;
  fromShane: boolean;
  message_type: 'text' | 'image' | 'file' | 'audio';
  attachment?: {
    url: string;
    type: string;
    name?: string;
    size?: number;
  };
  timestamp: Date;
  status: {
    delivered?: Date;
    read?: Date;
  };
}

const MessageSchema = new Schema<IMessage>({
  client_id: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  content: {
    type: String,
    required: true
  },
  fromShane: {
    type: Boolean,
    required: true,
    index: true
  },
  message_type: {
    type: String,
    enum: ['text', 'image', 'file', 'audio'],
    default: 'text'
  },
  // ✅ CORRECT: attachment as nested object
  attachment: {
    url: { type: String },
    type: { type: String },
    name: { type: String },
    size: { type: Number },
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  status: {
    delivered: { type: Date },
    read: { type: Date },
  },
});

// Indexes
MessageSchema.index({ client_id: 1, timestamp: -1 });
MessageSchema.index({ client_id: 1, fromShane: 1, 'status.read': 1 });

export default mongoose.model<IMessage>('Message', MessageSchema);
