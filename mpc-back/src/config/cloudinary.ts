// src/config/cloudinary.ts
import { v2 as cloudinary } from 'cloudinary';
import { Request } from 'express';
import multer from 'multer';

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Multer memory storage (don't save to disk)
const storage = multer.memoryStorage();

// File filter for images only
const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
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
  } else {
    cb(new Error('Only image files are allowed!'));
  }
};

// File filter for Excel files
const excelFileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
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

  console.log(
    'Uploading Excel file - mimetype:',
    file.mimetype,
    'extension:',
    fileExtension,
    'filename:',
    file.originalname
  );

  // Check either MIME type OR file extension
  if (
    allowedMimeTypes.includes(file.mimetype) ||
    allowedExtensions.includes(fileExtension)
  ) {
    cb(null, true);
  } else {
    cb(
      new Error(
        `Only Excel files are allowed! Received: ${file.mimetype} with extension ${fileExtension}`
      )
    );
  }
};

// Multer upload middleware for images
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max
  },
});

// Multer upload middleware for Excel files
export const uploadExcel = multer({
  storage: storage,
  fileFilter: excelFileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max for Excel files
  },
});

// Upload buffer to Cloudinary
export async function uploadToCloudinary(
  fileBuffer: Buffer,
  fileName: string,
  folder: string = 'chat-images'
): Promise<CloudinaryUploadResult> {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: folder,
        public_id: `${Date.now()}-${fileName.split('.')[0]}`,
        resource_type: 'image',
        transformation: [
          { width: 1920, height: 1080, crop: 'limit' }, // Max dimensions
          { quality: 'auto:good' }, // Auto quality
          { fetch_format: 'auto' }, // Auto format (WebP for supported browsers)
        ],
      },
      (error, result) => {
        if (error) {
          console.error('Cloudinary upload error:', error);
          reject(error);
        } else {
          resolve({
            url: result!.secure_url,
            publicId: result!.public_id,
            format: result!.format,
            width: result!.width,
            height: result!.height,
            bytes: result!.bytes,
          });
        }
      }
    );

    // Write buffer to stream
    uploadStream.end(fileBuffer);
  });
}

// Upload Excel file to Cloudinary (as raw file)
export async function uploadExcelToCloudinary(
  fileBuffer: Buffer,
  fileName: string,
  folder: string = 'training_plans'
): Promise<CloudinaryUploadResult> {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: folder,
        public_id: `${Date.now()}-${fileName.split('.')[0]}`,
        resource_type: 'raw', // Use 'raw' for non-image files
        format: fileName.split('.').pop(),
      },
      (error, result) => {
        if (error) {
          console.error('Excel Cloudinary upload error:', error);
          reject(error);
        } else {
          resolve({
            url: result!.secure_url,
            publicId: result!.public_id,
            format: result!.format,
            width: 0,
            height: 0,
            bytes: result!.bytes,
          });
        }
      }
    );

    // Write buffer to stream
    uploadStream.end(fileBuffer);
  });
}

// Delete image from Cloudinary
export async function deleteFromCloudinary(publicId: string): Promise<void> {
  try {
    await cloudinary.uploader.destroy(publicId);
    console.log(`Deleted image: ${publicId}`);
  } catch (error) {
    console.error('Cloudinary delete error:', error);
    throw error;
  }
}

// TypeScript interface for upload result
interface CloudinaryUploadResult {
  url: string;
  publicId: string;
  format: string;
  width: number;
  height: number;
  bytes: number;
}

export { cloudinary };
