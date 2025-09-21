export interface IMessage extends Document {
  roomId: string;
  clientId: string;
  fromShane: boolean;
  content: string;
  timestamp: Date;
  type: string;
  status: {
    sent: boolean;
    delivered: boolean;
    read: boolean;
  };
  attachment: {
    type: string;
    url: string;
    thumbnailUrl?: string;
    metadata?: any;
  };
  workoutData: {
    exerciseName: string;
    sets: number;
    reps: number;
    rir: number;
    weight: number;
  } | null;
}

import mongoose, { Schema } from "mongoose";

const MessageSchema = new Schema<IMessage>({
  roomId: { type: String, required: true },
  clientId: { type: String, required: true },
  fromShane: { type: Boolean, required: true },
  content: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  type: { type: String, required: true }, // e.g., text, image, video, workout
  status: {
    sent: { type: Boolean, default: false },
    delivered: { type: Boolean, default: false },
    read: { type: Boolean, default: false },
  },
  attachment: {
    type: {
      type: String,
      enum: ["image", "video", "file", "none"],
      default: "none",
    },
    url: { type: String },
    thumbnailUrl: { type: String },
    metadata: { type: Schema.Types.Mixed },
  },
  workoutData: {
    exerciseName: { type: String },
    sets: { type: Number },
    reps: { type: Number },
    rir: { type: Number },
    weight: { type: Number },
  },
});

const Message = mongoose.model<IMessage>("Message", MessageSchema);
export default Message;
