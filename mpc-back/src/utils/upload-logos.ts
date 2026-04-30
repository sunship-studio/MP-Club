// Utility script to upload logo images to Cloudinary
// Usage: npx ts-node src/utils/upload-logos.ts <path-to-logo>

import fs from 'fs';
import { cloudinary } from '../config/cloudinary';

async function uploadLogo(filePath: string, logoType: 'dark' | 'light') {
  try {
    if (!fs.existsSync(filePath)) {
      console.error(`❌ File not found: ${filePath}`);
      return;
    }

    console.log(`📤 Uploading ${logoType} logo from: ${filePath}`);

    const result = await cloudinary.uploader.upload(filePath, {
      folder: 'mpc-logos',
      public_id: `mpc_${logoType}_logo`,
      overwrite: true, // Overwrite if exists
      resource_type: 'image',
    });

    console.log(`✅ ${logoType} logo uploaded successfully!`);
    console.log(`🔗 URL: ${result.secure_url}`);
    console.log(`📋 Copy this URL and update your email template\n`);

    return result.secure_url;
  } catch (error) {
    console.error(`❌ Error uploading ${logoType} logo:`, error);
  }
}

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(
      'Usage: npx ts-node src/utils/upload-logos.ts <dark-logo-path> [light-logo-path]'
    );
    console.log('\nExample:');
    console.log(
      '  npx ts-node src/utils/upload-logos.ts ./logos/dark-logo.png ./logos/light-logo.png'
    );
    console.log(
      '\nIf you only provide one logo, it will be used as the dark logo.'
    );
    process.exit(1);
  }

  const darkLogoPath = args[0];
  const lightLogoPath = args[1] || args[0]; // Use dark logo if light logo not provided

  console.log('🚀 Starting logo upload to Cloudinary...\n');

  const darkUrl = await uploadLogo(darkLogoPath, 'dark');
  const lightUrl = await uploadLogo(lightLogoPath, 'light');

  if (darkUrl && lightUrl) {
    console.log('\n📝 Update these URLs in your email templates:');
    console.log('\nDark logo (top of email, on dark background):');
    console.log(darkUrl);
    console.log('\nLight logo (footer, on light background):');
    console.log(lightUrl);
  }
}

main();
