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
exports.cloudinary = exports.uploadVideo = exports.uploadExcel = exports.upload = void 0;
exports.uploadToCloudinary = uploadToCloudinary;
exports.uploadExcelToCloudinary = uploadExcelToCloudinary;
exports.deleteFromCloudinary = deleteFromCloudinary;
exports.uploadVideoToCloudinary = uploadVideoToCloudinary;
exports.deleteVideoFromCloudinary = deleteVideoFromCloudinary;
// src/config/cloudinary.ts
const cloudinary_1 = require("cloudinary");
Object.defineProperty(exports, "cloudinary", { enumerable: true, get: function () { return cloudinary_1.v2; } });
const dotenv_1 = __importDefault(require("dotenv"));
const multer_1 = __importDefault(require("multer"));
dotenv_1.default.config();
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
    const allowedTypes = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif',
        'image/webp',
    ];
    console.log('Uploading file of type:', file.mimetype);
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    }
    else {
        cb(new Error('Only image files are allowed!'));
    }
};
// File filter for Excel files
const excelFileFilter = (req, file, cb) => {
    const allowedMimeTypes = [
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel.sheet.macroEnabled.12',
        'application/octet-stream', // Some systems send Excel as binary stream
    ];
    const allowedExtensions = ['.xls', '.xlsx', '.xlsm'];
    const fileExtension = file.originalname
        .toLowerCase()
        .substring(file.originalname.lastIndexOf('.'));
    console.log('Uploading Excel file - mimetype:', file.mimetype, 'extension:', fileExtension, 'filename:', file.originalname);
    // Check either MIME type OR file extension
    if (allowedMimeTypes.includes(file.mimetype) ||
        allowedExtensions.includes(fileExtension)) {
        cb(null, true);
    }
    else {
        cb(new Error(`Only Excel files are allowed! Received: ${file.mimetype} with extension ${fileExtension}`));
    }
};
// Multer upload middleware for images
exports.upload = (0, multer_1.default)({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB max
    },
});
// Multer upload middleware for Excel files
exports.uploadExcel = (0, multer_1.default)({
    storage: storage,
    fileFilter: excelFileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB max for Excel files
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
                    { fetch_format: 'auto' }, // Auto format (WebP for supported browsers)
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
// Upload Excel file to Cloudinary (as raw file)
function uploadExcelToCloudinary(fileBuffer_1, fileName_1) {
    return __awaiter(this, arguments, void 0, function* (fileBuffer, fileName, folder = 'training_plans') {
        return new Promise((resolve, reject) => {
            const uploadStream = cloudinary_1.v2.uploader.upload_stream({
                folder: folder,
                public_id: `${Date.now()}-${fileName.split('.')[0]}`,
                resource_type: 'raw', // Use 'raw' for non-image files
                format: fileName.split('.').pop(),
            }, (error, result) => {
                if (error) {
                    console.error('Excel Cloudinary upload error:', error);
                    reject(error);
                }
                else {
                    resolve({
                        url: result.secure_url,
                        publicId: result.public_id,
                        format: result.format,
                        width: 0,
                        height: 0,
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
// File filter for video files
const videoFileFilter = (req, file, cb) => {
    const allowedMimeTypes = [
        'video/mp4',
        'video/quicktime',
        'video/x-msvideo',
        'video/x-ms-wmv',
        'video/webm',
        'video/mpeg',
    ];
    const allowedExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.webm', '.mpeg'];
    const fileExtension = file.originalname
        .toLowerCase()
        .substring(file.originalname.lastIndexOf('.'));
    console.log('Uploading video file - mimetype:', file.mimetype, 'extension:', fileExtension, 'filename:', file.originalname);
    if (allowedMimeTypes.includes(file.mimetype) ||
        allowedExtensions.includes(fileExtension)) {
        cb(null, true);
    }
    else {
        cb(new Error(`Only video files are allowed! Received: ${file.mimetype} with extension ${fileExtension}`));
    }
};
// Multer upload middleware for videos
exports.uploadVideo = (0, multer_1.default)({
    storage: storage,
    fileFilter: videoFileFilter,
    limits: {
        fileSize: 100 * 1024 * 1024, // 100MB max for video files
    },
});
// Upload video buffer to Cloudinary
function uploadVideoToCloudinary(fileBuffer_1, fileName_1) {
    return __awaiter(this, arguments, void 0, function* (fileBuffer, fileName, folder = 'exercises') {
        return new Promise((resolve, reject) => {
            const uploadStream = cloudinary_1.v2.uploader.upload_stream({
                folder: folder,
                public_id: `${Date.now()}-${fileName.split('.')[0]}`,
                resource_type: 'video',
                eager: [
                    { width: 720, height: 1280, crop: 'limit' }, // Max dimensions for mobile
                ],
                eager_async: true,
            }, (error, result) => {
                if (error) {
                    console.error('Video Cloudinary upload error:', error);
                    reject(error);
                }
                else {
                    resolve({
                        url: result.secure_url,
                        publicId: result.public_id,
                        format: result.format,
                        width: result.width || 0,
                        height: result.height || 0,
                        bytes: result.bytes,
                        duration: result.duration,
                    });
                }
            });
            uploadStream.end(fileBuffer);
        });
    });
}
// Delete video from Cloudinary
function deleteVideoFromCloudinary(publicId) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            yield cloudinary_1.v2.uploader.destroy(publicId, { resource_type: 'video' });
            console.log(`Deleted video: ${publicId}`);
        }
        catch (error) {
            console.error('Cloudinary video delete error:', error);
            throw error;
        }
    });
}
