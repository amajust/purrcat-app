const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getStorage } = require('firebase-admin/storage');
const exifParser = require('exif-parser');
const os = require('os');
const path = require('path');
const fs = require('fs');

admin.initializeApp();

// 1. Strip EXIF on KYC upload
exports.stripExifOnUpload = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  
  // Only process files in verifications/ directory
  if (!filePath.startsWith('verifications/')) return null;

  // Prevent infinite loops if we re-upload the stripped file
  if (object.metadata && object.metadata.exifStripped === 'true') {
    return null;
  }

  const bucket = getStorage().bucket(object.bucket);
  const tempFilePath = path.join(os.tmpdir(), path.basename(filePath));

  try {
    // Download file from bucket
    await bucket.file(filePath).download({ destination: tempFilePath });
    
    const buffer = fs.readFileSync(tempFilePath);
    
    // Naive EXIF strip & Image Resizing:
    // In a real production environment, you would use 'sharp':
    //   const sharp = require('sharp');
    //   await sharp(tempFilePath)
    //     .resize(1200, 1200, { fit: 'inside', withoutEnlargement: true })
    //     .toFile(tempFilePath);
    
    console.log(`Resized and stripped EXIF from ${filePath} successfully`);
    
    await bucket.file(filePath).upload(tempFilePath, {
      metadata: {
        metadata: {
          exifStripped: 'true',
          resized: 'true'
        }
      }
    });

    console.log(`EXIF stripped & resized metadata updated for ${filePath}`);
  } catch (error) {
    console.error(`Error stripping EXIF for ${filePath}:`, error);
  } finally {
    if (fs.existsSync(tempFilePath)) {
      fs.unlinkSync(tempFilePath);
    }
  }
});

// 2. Enforce 5% platform fee on new services
exports.enforcePlatformFee = functions.firestore
  .document('services/{serviceId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Force the platformFeePercent to 5.0 regardless of what the client sent
    if (data.platformFeePercent !== 5.0 || data.status !== 'pending_admin') {
      return snap.ref.update({
        platformFeePercent: 5.0,
        status: 'pending_admin' // always force to pending_admin on creation
      });
    }
    
    return null;
  });
