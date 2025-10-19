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
exports.ChatController = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const cloudinary_1 = require("../../config/cloudinary");
const ChatRoom_1 = __importDefault(require("../../models/ChatRoom"));
const Message_1 = __importDefault(require("../../models/Message"));
class ChatController {
    // Get specific chat room
    static getChatRoom(clientId) {
        return __awaiter(this, void 0, void 0, function* () {
            return ChatRoom_1.default.findOne({
                clientId: new mongoose_1.default.Types.ObjectId(clientId),
            }).populate("clientId", "name email avatar");
        });
    }
    // Send a message
    static sendMessage(data) {
        return __awaiter(this, void 0, void 0, function* () {
            const now = new Date();
            const message = new Message_1.default(Object.assign(Object.assign({}, data), { timestamp: now, status: {
                    delivered: now,
                } }));
            yield message.save();
            // Update chat room
            yield this.updateChatRoom(data.client_id, message);
            return message;
        });
    }
    // Upload Image
    static uploadImage(fileBuffer, fileName, mimeType) {
        return __awaiter(this, void 0, void 0, function* () {
            const uploadResult = yield (0, cloudinary_1.uploadToCloudinary)(fileBuffer, fileName);
            console.log('Upload Result:', uploadResult);
            return {
                url: uploadResult.url,
                type: mimeType,
                name: fileName,
                size: fileBuffer.length,
            };
        });
    }
    // Update chat room with last message
    static updateChatRoom(clientId, message) {
        return __awaiter(this, void 0, void 0, function* () {
            return ChatRoom_1.default.findOneAndUpdate({ clientId: new mongoose_1.default.Types.ObjectId(clientId) }, {
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
            }, { new: true, upsert: true });
        });
    }
    // Mark messages as read
    static markAsRead(clientId, fromShane) {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield Message_1.default.updateMany({
                client_id: new mongoose_1.default.Types.ObjectId(clientId),
                fromShane: fromShane,
                "status.read": { $exists: false },
            }, {
                $set: {
                    "status.read": new Date(),
                },
            });
            // Reset unread count
            yield ChatRoom_1.default.updateOne({ clientId: new mongoose_1.default.Types.ObjectId(clientId) }, {
                $set: {
                    [`unread_count.${fromShane ? "client" : "shane"}`]: 0,
                },
            });
            return result;
        });
    }
    // Mark message as delivered
    static markAsDelivered(messageId) {
        return __awaiter(this, void 0, void 0, function* () {
            return Message_1.default.findByIdAndUpdate(messageId, {
                $set: {
                    "status.delivered": new Date(),
                },
            }, { new: true });
        });
    }
    // Get messages with pagination
    static getMessages(clientId_1) {
        return __awaiter(this, arguments, void 0, function* (clientId, limit = 50, before) {
            const query = {
                client_id: new mongoose_1.default.Types.ObjectId(clientId),
            };
            if (before) {
                query.timestamp = { $lt: before };
            }
            return Message_1.default.find(query).sort({ timestamp: -1 }).limit(limit).lean();
        });
    }
    // Get unread count
    static getUnreadCount(clientId, forShane) {
        return __awaiter(this, void 0, void 0, function* () {
            return Message_1.default.countDocuments({
                client_id: new mongoose_1.default.Types.ObjectId(clientId),
                fromShane: forShane,
                "status.read": { $exists: false },
            });
        });
    }
    // Get total unread count for Shane (across all clients)
    static getTotalUnreadForShane() {
        return __awaiter(this, void 0, void 0, function* () {
            const result = yield Message_1.default.aggregate([
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
        });
    }
    // Create or get chat room
    static getOrCreateChatRoom(clientId) {
        return __awaiter(this, void 0, void 0, function* () {
            let chatRoom = yield this.getChatRoom(clientId);
            if (!chatRoom) {
                chatRoom = yield ChatRoom_1.default.create({
                    clientId: new mongoose_1.default.Types.ObjectId(clientId),
                    created_at: new Date(),
                    unread_count: {
                        shane: 0,
                        client: 0,
                    },
                });
            }
            return chatRoom;
        });
    }
}
exports.ChatController = ChatController;
