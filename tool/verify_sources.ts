/**
 * Verify RSS Sources in Firestore
 *
 * Checks that sources were seeded correctly
 *
 * Usage:
 *   FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/verify_sources.ts
 */

import admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'brightside-9a2c5'
});

const db = admin.firestore();
const metros = ['slc', 'nyc', 'gsp'];

async function verifySources() {
  console.log('🔍 Verifying RSS sources in Firestore...');
  console.log('');

  for (const metroId of metros) {
    console.log(`📍 Metro: ${metroId}`);

    try {
      const sourcesDoc = await db
        .collection('system')
        .doc('sources')
        .collection(metroId)
        .doc('sources')
        .get();

      if (!sourcesDoc.exists) {
        console.log(`   ❌ No sources document found`);
        console.log('');
        continue;
      }

      const sourcesData = sourcesDoc.data();
      if (!sourcesData) {
        console.log(`   ❌ Sources document is empty`);
        console.log('');
        continue;
      }

      const sourceIds = Object.keys(sourcesData);
      console.log(`   ✅ Found ${sourceIds.length} sources`);
      console.log('');

      for (const sourceId of sourceIds) {
        const source = sourcesData[sourceId];
        console.log(`   📰 ${sourceId}:`);
        console.log(`      Name: ${source.source_name}`);
        console.log(`      URL: ${source.rss_url}`);
        console.log(`      Weight: ${source.weight}`);
        console.log(`      Active: ${source.active}`);
        console.log('');
      }
    } catch (error) {
      console.error(`   ❌ Error fetching sources: ${error}`);
      console.log('');
    }
  }

  console.log('✅ Verification complete');
  process.exit(0);
}

verifySources().catch((error) => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});
