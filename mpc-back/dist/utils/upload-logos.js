"use strict";
// Utility script to upload logo images to Cloudinary
// Usage: npx ts-node src/utils/upload-logos.ts <path-to-logo>
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
const fs_1 = __importDefault(require("fs"));
const cloudinary_1 = require("../config/cloudinary");
function uploadLogo(filePath, logoType) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            if (!fs_1.default.existsSync(filePath)) {
                console.error(`❌ File not found: ${filePath}`);
                return;
            }
            console.log(`📤 Uploading ${logoType} logo from: ${filePath}`);
            const result = yield cloudinary_1.cloudinary.uploader.upload(filePath, {
                folder: 'mpc-logos',
                public_id: `mpc_${logoType}_logo`,
                overwrite: true, // Overwrite if exists
                resource_type: 'image',
            });
            console.log(`✅ ${logoType} logo uploaded successfully!`);
            console.log(`🔗 URL: ${result.secure_url}`);
            console.log(`📋 Copy this URL and update your email template\n`);
            return result.secure_url;
        }
        catch (error) {
            console.error(`❌ Error uploading ${logoType} logo:`, error);
        }
    });
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const args = process.argv.slice(2);
        if (args.length === 0) {
            console.log('Usage: npx ts-node src/utils/upload-logos.ts <dark-logo-path> [light-logo-path]');
            console.log('\nExample:');
            console.log('  npx ts-node src/utils/upload-logos.ts ./logos/dark-logo.png ./logos/light-logo.png');
            console.log('\nIf you only provide one logo, it will be used as the dark logo.');
            process.exit(1);
        }
        const darkLogoPath = args[0];
        const lightLogoPath = args[1] || args[0]; // Use dark logo if light logo not provided
        console.log('🚀 Starting logo upload to Cloudinary...\n');
        const darkUrl = yield uploadLogo(darkLogoPath, 'dark');
        const lightUrl = yield uploadLogo(lightLogoPath, 'light');
        if (darkUrl && lightUrl) {
            console.log('\n📝 Update these URLs in your email templates:');
            console.log('\nDark logo (top of email, on dark background):');
            console.log(darkUrl);
            console.log('\nLight logo (footer, on light background):');
            console.log(lightUrl);
        }
    });
}
main();
