/**
 * Manual RSS Ingestion Runner
 *
 * Runs ingestion for specified metros and logs results
 *
 * Usage:
 *   FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/run_ingestion.ts  # Dev
 *   npx ts-node tool/run_ingestion.ts                                            # Prod
 */

import admin from 'firebase-admin';
import { runIngest } from '../functions/src/ingest/runIngest';

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'brightside-9a2c5'
});

const metros = ['slc', 'nyc', 'gsp'];

async function runIngestionForAll() {
  console.log('🚀 Starting manual RSS ingestion...');
  console.log('');

  const results: Record<string, { success: boolean; count?: number; error?: string }> = {};

  for (const metroId of metros) {
    console.log(`📍 Processing metro: ${metroId}`);
    console.log('─'.repeat(60));

    try {
      const count = await runIngest(metroId);

      results[metroId] = {
        success: true,
        count: count
      };

      console.log('');
      console.log(`✅ ${metroId}: Successfully ingested ${count} articles`);
      console.log('');
    } catch (error) {
      results[metroId] = {
        success: false,
        error: String(error)
      };

      console.error('');
      console.error(`❌ ${metroId}: Ingestion failed`);
      console.error(`   Error: ${error}`);
      console.error('');
    }
  }

  // Print summary
  console.log('═'.repeat(60));
  console.log('📊 INGESTION SUMMARY');
  console.log('═'.repeat(60));
  console.log('');

  let totalArticles = 0;
  let successCount = 0;
  let failCount = 0;

  for (const metroId of metros) {
    const result = results[metroId];

    if (result.success) {
      console.log(`✅ ${metroId}: ${result.count} articles`);
      totalArticles += result.count || 0;
      successCount++;
    } else {
      console.log(`❌ ${metroId}: FAILED`);
      console.log(`   ${result.error}`);
      failCount++;
    }
  }

  console.log('');
  console.log(`Total articles ingested: ${totalArticles}`);
  console.log(`Successful metros: ${successCount}/${metros.length}`);
  console.log(`Failed metros: ${failCount}/${metros.length}`);
  console.log('');
  console.log('═'.repeat(60));

  process.exit(failCount > 0 ? 1 : 0);
}

runIngestionForAll().catch((error) => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});
