import { v2 as cloudinary } from 'cloudinary';
import mongoose from 'mongoose';
import path from 'path';
import connectToDatabase from './config/database';
import Exercise from './models/Exercise'; // adjust path to your model
import videoMapping from './video-mapping.json';

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const VIDEOS_FOLDER = './src/videos-compressed'; // folder with your .mov files

interface VideoMap {
  fileName: string;
  exerciseName: string;
  isNew?: boolean;
  bodyParts?: string[];
}
interface VideoUploadResponse {
  secure_url: string;
  duration?: number;
  width?: number;
  height?: number;
  format?: string;
  bytes?: number;
  public_id?: string;
}

async function uploadVideo(fileName: string): Promise<[string, number]> {
  const filePath = path.join(VIDEOS_FOLDER, fileName);

  const publicId = fileName
    .replace(/\.[^/.]+$/, '')
    .toLowerCase()
    .replace(/\s+/g, '-');

  console.log(`  Uploading to Cloudinary...`);

  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload(
      filePath,
      {
        resource_type: 'video',
        folder: 'exercises',
        public_id: publicId,
        overwrite: true,
      },
      (error, result) => {
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
      }
    );
  });
}
async function seed() {
  // Connect to MongoDB
  connectToDatabase();
  let successCount = 0;
  let failCount = 0;

  for (const mapping of videoMapping as VideoMap[]) {
    const { fileName, exerciseName, isNew, bodyParts } = mapping;

    try {
      console.log(`Processing: ${fileName} → ${exerciseName}`);

      // Upload video to Cloudinary
      const video = await uploadVideo(fileName);

      if (isNew && bodyParts) {
        // Create new exercise
        await Exercise.create({
          name: exerciseName,
          videoUrl: video[0],
          videoLengthSeconds: video[1],
          bodyParts,
        });
        console.log(`  ✓ Created new exercise: ${exerciseName}`);
      } else {
        const result = await Exercise.findOneAndUpdate(
          { name: exerciseName },
          { videoLengthSeconds: video[1], videoUrl: video[0] },
          { new: true }
        );

        if (result) {
          console.log(`  ✓ Updated: ${exerciseName}`);
        } else {
          console.log(`  ⚠ Exercise not found: ${exerciseName}`);
        }
      }

      console.log(`  → ${video[0]}\n`);
      successCount++;
    } catch (err) {
      ``;
      console.error(`  ✗ Failed: ${exerciseName}`, err);
      failCount++;
    }
  }

  console.log('========================================');
  console.log(`Done! Success: ${successCount}, Failed: ${failCount}`);
  console.log('========================================');

  await mongoose.disconnect();
}

seed().catch((error) => {
  console.error('Error seeding exercises:', error);
  mongoose.disconnect();
});

export default seed;
