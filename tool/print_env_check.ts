/**
 * Environment check script
 * 
 * Prints current environment configuration for verification before deployment.
 * 
 * Usage:
 *   FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts   # Dev mode
 *   npx ts-node tool/print_env_check.ts                                            # Prod mode
 */

import admin from 'firebase-admin';

// Environment detection
const isProd = !process.env.FIRESTORE_EMULATOR_HOST;
const env = isProd ? 'PRODUCTION' : 'DEVELOPMENT';

async function main() {
  console.log('');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  BrightSide Environment Check');
  console.log('═══════════════════════════════════════════════════════════');
  console.log('');

  // 1. Environment
  console.log('📦 ENVIRONMENT');
  console.log(`   Environment: ${env}`);
  console.log(`   isProd: ${isProd}`);
  console.log(`   isDev: ${!isProd}`);
  if (!isProd) {
    console.log(`   Emulator Host: ${process.env.FIRESTORE_EMULATOR_HOST}`);
  }
  console.log('');

  try {
    // Initialize Firebase Admin
    admin.initializeApp({
      projectId: 'brightside-9a2c5'
    });

    const db = admin.firestore();
    const projectId = 'brightside-9a2c5';

    // 2. Firebase Configuration
    console.log('🔥 FIREBASE CONFIGURATION');
    console.log(`   Project ID: ${projectId}`);
    if (!isProd) {
      console.log(`   Using Emulators: ✓`);
    } else {
      console.log(`   Using Production Firebase: ✓`);
    }
    console.log('');

    // 3. System Configuration
    console.log('⚙️  SYSTEM CONFIGURATION');
    try {
      const configDoc = await db.collection('system').doc('config').get();

      if (configDoc.exists) {
        const data = configDoc.data() as Record<string, any>;
        
        const privacyUrl = data.privacy_policy_url || 'Not set';
        const termsUrl = data.terms_of_service_url || 'Not set';
        const supportEmail = data.support_email || 'Not set';
        const maintenanceMode = data.maintenance_mode || false;
        const todayMaxArticles = data.today_max_articles || 5;

        console.log(`   Privacy Policy URL: ${privacyUrl}`);
        console.log(`   Terms of Service URL: ${termsUrl}`);
        console.log(`   Support Email: ${supportEmail}`);
        console.log(`   Maintenance Mode: ${maintenanceMode ? '⚠️  ENABLED' : '✓ Disabled'}`);
        console.log(`   Max Articles (Today): ${todayMaxArticles}`);
        
        // Verify URLs are accessible (only in prod)
        if (isProd) {
          await verifyUrl(privacyUrl, 'Privacy Policy');
          await verifyUrl(termsUrl, 'Terms of Service');
        }
      } else {
        console.log('   ⚠️  System config document not found');
        console.log('   Run: npx ts-node tool/seed_system_config.ts');
      }
    } catch (e) {
      console.log(`   ❌ Failed to fetch system config: ${e}`);
    }
    console.log('');

    // 4. Health Check
    console.log('🏥 SYSTEM HEALTH');
    try {
      const healthDoc = await db.collection('system').doc('health').get();

      if (healthDoc.exists) {
        const data = healthDoc.data() as Record<string, any>;
        const metros = ['slc', 'nyc', 'gsp'];

        for (const metroId of metros) {
          const metroData = data[metroId] as Record<string, any> | undefined;
          
          if (metroData) {
            console.log(`   Metro: ${metroId.toUpperCase()}`);
            
            if (metroData.lastIngestAt) {
              const ingestDate = metroData.lastIngestAt.toDate();
              const ingestAge = Date.now() - ingestDate.getTime();
              const ingestHours = Math.floor(ingestAge / (1000 * 60 * 60));
              const ingestStatus = ingestHours < 24 ? '✓' : '⚠️';
              console.log(`     Last Ingest: ${formatDate(ingestDate)} ${ingestStatus}`);
              console.log(`       (${formatAge(ingestAge)} ago)`);
            } else {
              console.log(`     Last Ingest: Never ❌`);
            }

            if (metroData.lastDigestAt) {
              const digestDate = metroData.lastDigestAt.toDate();
              const digestAge = Date.now() - digestDate.getTime();
              const digestHours = Math.floor(digestAge / (1000 * 60 * 60));
              const digestStatus = digestHours < 24 ? '✓' : '⚠️';
              console.log(`     Last Digest: ${formatDate(digestDate)} ${digestStatus}`);
              console.log(`       (${formatAge(digestAge)} ago)`);
            } else {
              console.log(`     Last Digest: Never ❌`);
            }
            console.log('');
          } else {
            console.log(`   Metro: ${metroId.toUpperCase()} - No health data ⚠️`);
            console.log('');
          }
        }
      } else {
        console.log('   ⚠️  Health document not found');
        console.log('   Schedulers may not have run yet');
      }
    } catch (e) {
      console.log(`   ❌ Failed to fetch health data: ${e}`);
    }
    console.log('');

    // 5. Stories Count
    console.log('📰 CONTENT STATUS');
    try {
      const metros = ['slc', 'nyc', 'gsp'];
      
      for (const metroId of metros) {
        const snapshot = await db
          .collection('stories')
          .where('metro_id', '==', metroId)
          .where('status', '==', 'published')
          .limit(10)
          .get();

        const count = snapshot.size;
        console.log(`   ${metroId.toUpperCase()}: ${count} published ${count === 1 ? 'story' : 'stories'} ${count > 0 ? '✓' : '⚠️'}`);
      }
    } catch (e) {
      console.log(`   ❌ Failed to check stories: ${e}`);
    }
    console.log('');

    // 6. Warnings
    console.log('⚠️  WARNINGS & RECOMMENDATIONS');
    console.log('');
    
    if (isProd) {
      console.log('   ✓ Running in PRODUCTION mode');
      console.log('   • Ensure legal URLs are publicly accessible');
      console.log('   • Verify APNs key is configured in Firebase Console');
      console.log('   • Check Crashlytics is enabled');
      console.log('   • Monitor health checks for all metros');
      console.log('');
      
      // Check for critical issues
      const configDoc = await db.collection('system').doc('config').get();
      if (!configDoc.exists) {
        console.log('   ❌ CRITICAL: System config not found!');
      }
      
      const healthDoc = await db.collection('system').doc('health').get();
      if (!healthDoc.exists) {
        console.log('   ⚠️  WARNING: No health data - schedulers may not be running');
      }
    } else {
      console.log('   ⚠️  Running in DEVELOPMENT mode');
      console.log('   • Using Firebase emulators');
      console.log('   • Debug features enabled');
      console.log('   • For production, unset FIRESTORE_EMULATOR_HOST');
    }
    console.log('');

    console.log('═══════════════════════════════════════════════════════════');
    console.log('  Environment check complete');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');

    process.exit(0);
  } catch (e) {
    console.log('');
    console.log('❌ FATAL ERROR');
    console.log(`   ${e}`);
    console.log('');
    if ((e as any).stack) {
      console.log('Stack trace:');
      console.log((e as any).stack);
    }
    console.log('');
    process.exit(1);
  }
}

/**
 * Format date for display
 */
function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  
  return `${year}-${month}-${day} ${hour}:${minute}`;
}

/**
 * Format age (duration) for display
 */
function formatAge(durationMs: number): string {
  const days = Math.floor(durationMs / (1000 * 60 * 60 * 24));
  const hours = Math.floor((durationMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((durationMs % (1000 * 60 * 60)) / (1000 * 60));

  if (days > 0) {
    return `${days}d ${hours}h`;
  } else if (hours > 0) {
    return `${hours}h ${minutes}m`;
  } else {
    return `${minutes}m`;
  }
}

/**
 * Verify URL is accessible
 */
async function verifyUrl(url: string, name: string): Promise<void> {
  if (url === 'Not set') {
    console.log(`     ${name} URL: ❌ Not configured`);
    return;
  }

  try {
    const response = await fetch(url, {
      method: 'HEAD',
      headers: { 'User-Agent': 'BrightSide-EnvCheck/1.0' }
    });
    
    if (response.ok) {
      console.log(`     ${name} URL: ✓ Accessible (HTTP ${response.status})`);
    } else {
      console.log(`     ${name} URL: ⚠️  HTTP ${response.status}`);
    }
  } catch (e) {
    console.log(`     ${name} URL: ❌ Not accessible (${e})`);
  }
}

main();
