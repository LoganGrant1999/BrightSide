/**
 * Seed system configuration to Firestore
 *
 * Creates /system/config document with app-wide settings
 *
 * Run with: npx ts-node tool/seed_system_config.ts
 */

import admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'brightside-9a2c5'
});

const db = admin.firestore();

async function seedSystemConfig() {
  console.log('🌱 Seeding system configuration...');

  const systemConfig = {
    // Legal URLs (Firebase Hosting - deployed to brightside-9a2c5.web.app)
    privacy_policy_url: 'https://brightside-9a2c5.web.app/privacy',
    terms_of_service_url: 'https://brightside-9a2c5.web.app/terms',

    // Support contact
    support_email: 'support@brightside.com',

    // Feature flags and limits
    today_max_articles: 5,
    maintenance_mode: false,

    // App Store metadata (update before App Store submission)
    app_store_url: 'https://apps.apple.com/app/brightside/id123456789',
    play_store_url: 'https://play.google.com/store/apps/details?id=com.brightside.app',

    // Metadata
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  try {
    await db.collection('system').doc('config').set(systemConfig, { merge: true });
    console.log('✅ System config seeded successfully');
    console.log('');
    console.log('📋 Configuration:');
    console.log(`   Privacy Policy: ${systemConfig.privacy_policy_url}`);
    console.log(`   Terms of Service: ${systemConfig.terms_of_service_url}`);
    console.log(`   Support Email: ${systemConfig.support_email}`);
    console.log(`   Max Articles/Day: ${systemConfig.today_max_articles}`);
    console.log(`   Maintenance Mode: ${systemConfig.maintenance_mode}`);
    console.log('');
    console.log('⚠️  Remember to update URLs before production deployment!');
  } catch (error) {
    console.error('❌ Failed to seed system config:', error);
    process.exit(1);
  }

  process.exit(0);
}

seedSystemConfig();
