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
const cloudinary_1 = require("cloudinary");
const mongoose_1 = __importDefault(require("mongoose"));
const path_1 = __importDefault(require("path"));
const database_1 = __importDefault(require("./config/database"));
const Exercise_1 = __importDefault(require("./models/Exercise")); // adjust path to your model
const video_mapping_json_1 = __importDefault(require("./video-mapping.json"));
// Configure Cloudinary
cloudinary_1.v2.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});
const VIDEOS_FOLDER = './src/videos-compressed'; // folder with your .mov files
function uploadVideo(fileName) {
    return __awaiter(this, void 0, void 0, function* () {
        const filePath = path_1.default.join(VIDEOS_FOLDER, fileName);
        const publicId = fileName
            .replace(/\.[^/.]+$/, '')
            .toLowerCase()
            .replace(/\s+/g, '-');
        console.log(`  Uploading to Cloudinary...`);
        return new Promise((resolve, reject) => {
            cloudinary_1.v2.uploader.upload(filePath, {
                resource_type: 'video',
                folder: 'exercises',
                public_id: publicId,
                overwrite: true,
            }, (error, result) => {
                if (error) {
                    reject(error);
                    return;
                }
                if (!result) {
                    reject(new Error('No result from Cloudinary'));
                    return;
                }
                console.log('Result:', result);
                const videoUrl = result.secure_url;
                const duration = Math.round(result.duration || 0);
                resolve([videoUrl, duration]);
            });
        });
    });
}
function seed() {
    return __awaiter(this, void 0, void 0, function* () {
        // Connect to MongoDB
        (0, database_1.default)();
        let successCount = 0;
        let failCount = 0;
        for (const mapping of video_mapping_json_1.default) {
            const { fileName, exerciseName, isNew, bodyParts } = mapping;
            try {
                console.log(`Processing: ${fileName} → ${exerciseName}`);
                // Upload video to Cloudinary
                const video = yield uploadVideo(fileName);
                if (isNew && bodyParts) {
                    // Create new exercise
                    yield Exercise_1.default.create({
                        name: exerciseName,
                        videoUrl: video[0],
                        videoLengthSeconds: video[1],
                        bodyParts,
                    });
                    console.log(`  ✓ Created new exercise: ${exerciseName}`);
                }
                else {
                    const result = yield Exercise_1.default.findOneAndUpdate({ name: exerciseName }, { videoLengthSeconds: video[1], videoUrl: video[0] }, { new: true });
                    if (result) {
                        console.log(`  ✓ Updated: ${exerciseName}`);
                    }
                    else {
                        console.log(`  ⚠ Exercise not found: ${exerciseName}`);
                    }
                }
                console.log(`  → ${video[0]}\n`);
                successCount++;
            }
            catch (err) {
                ``;
                console.error(`  ✗ Failed: ${exerciseName}`, err);
                failCount++;
            }
        }
        console.log('========================================');
        console.log(`Done! Success: ${successCount}, Failed: ${failCount}`);
        console.log('========================================');
        yield mongoose_1.default.disconnect();
    });
}
seed().catch((error) => {
    console.error('Error seeding exercises:', error);
    mongoose_1.default.disconnect();
});
exports.default = seed;
