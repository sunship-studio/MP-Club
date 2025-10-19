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
exports.cloudinary = exports.upload = void 0;
exports.uploadToCloudinary = uploadToCloudinary;
exports.deleteFromCloudinary = deleteFromCloudinary;
// src/config/cloudinary.ts
const cloudinary_1 = require("cloudinary");
Object.defineProperty(exports, "cloudinary", { enumerable: true, get: function () { return cloudinary_1.v2; } });
const multer_1 = __importDefault(require("multer"));
// Configure Cloudinary
cloudinary_1.v2.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});
// Multer memory storage (don't save to disk)
const storage = multer_1.default.memoryStorage();
// File filter for images only
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    console.log('Uploading file of type:', file.mimetype);
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    }
    else {
        cb(new Error('Only image files are allowed!'));
    }
};
// Multer upload middleware
exports.upload = (0, multer_1.default)({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB max
    },
});
// Upload buffer to Cloudinary
function uploadToCloudinary(fileBuffer_1, fileName_1) {
    return __awaiter(this, arguments, void 0, function* (fileBuffer, fileName, folder = 'chat-images') {
        return new Promise((resolve, reject) => {
            const uploadStream = cloudinary_1.v2.uploader.upload_stream({
                folder: folder,
                public_id: `${Date.now()}-${fileName.split('.')[0]}`,
                resource_type: 'image',
                transformation: [
                    { width: 1920, height: 1080, crop: 'limit' }, // Max dimensions
                    { quality: 'auto:good' }, // Auto quality
                    { fetch_format: 'auto' } // Auto format (WebP for supported browsers)
                ],
            }, (error, result) => {
                if (error) {
                    console.error('Cloudinary upload error:', error);
                    reject(error);
                }
                else {
                    resolve({
                        url: result.secure_url,
                        publicId: result.public_id,
                        format: result.format,
                        width: result.width,
                        height: result.height,
                        bytes: result.bytes,
                    });
                }
            });
            // Write buffer to stream
            uploadStream.end(fileBuffer);
        });
    });
}
// Delete image from Cloudinary
function deleteFromCloudinary(publicId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield cloudinary_1.v2.uploader.destroy(publicId);
            console.log(`Deleted image: ${publicId}`);
        }
        catch (error) {
            console.error('Cloudinary delete error:', error);
            throw error;
        }
    });
}
