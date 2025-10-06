#!/usr/bin/env ts-node
/**
 * Create Demo Reviewer Account for App Store Review
 *
 * Creates a demo account with:
 * - Email: demo@brightside.com
 * - Password: BrightDemo2025!
 * - Metro: Salt Lake City (slc)
 * - Optional: 2 draft submissions for testing moderation
 *
 * Usage:
 *   npx ts-node tool/make_demo_reviewer.ts
 *   npx ts-node tool/make_demo_reviewer.ts --with-submissions
 *
 * Environment:
 *   Development: FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/make_demo_reviewer.ts
 *   Production: npx ts-node tool/make_demo_reviewer.ts
 */

import admin from 'firebase-admin';

// Demo account credentials
const DEMO_EMAIL = 'demo@brightside.com';
const DEMO_PASSWORD = 'BrightDemo2025!';
const DEMO_METRO = 'slc';
const DEMO_DISPLAY_NAME = 'Demo Reviewer';

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'brightside-9a2c5'
});

const auth = admin.auth();
const db = admin.firestore();

/**
 * Create or update demo user account
 */
async function createDemoUser(): Promise<string> {
  console.log(`\n👤 Creating demo reviewer account...\n`);
  console.log(`   Email: ${DEMO_EMAIL}`);
  console.log(`   Password: ${DEMO_PASSWORD}`);
  console.log(`   Metro: ${DEMO_METRO}`);
  console.log('');

  try {
    // Check if user already exists
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(DEMO_EMAIL);
      console.log(`   ℹ️  User already exists (UID: ${userRecord.uid})`);
      console.log(`   ✓ Updating password...\n`);

      // Update password
      await auth.updateUser(userRecord.uid, {
        password: DEMO_PASSWORD,
        displayName: DEMO_DISPLAY_NAME,
      });
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        // Create new user
        console.log(`   ✓ Creating new user...\n`);
        userRecord = await auth.createUser({
          email: DEMO_EMAIL,
          password: DEMO_PASSWORD,
          displayName: DEMO_DISPLAY_NAME,
          emailVerified: true,
        });
      } else {
        throw error;
      }
    }

    const uid = userRecord.uid;

    // Create/update user document in Firestore
    const userDoc = {
      email: DEMO_EMAIL,
      display_name: DEMO_DISPLAY_NAME,
      chosen_metro: DEMO_METRO,
      notification_opt_in: false,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(uid).set(userDoc, { merge: true });

    console.log(`   ✓ User document created/updated in Firestore`);
    console.log(`   ✓ UID: ${uid}`);
    console.log('');

    return uid;
  } catch (error: any) {
    console.error(`\n❌ Error creating demo user:`, error.message);
    throw error;
  }
}

/**
 * Create draft submissions for testing moderation
 */
async function createDemoSubmissions(userId: string): Promise<void> {
  console.log(`\n📝 Creating demo submissions...\n`);

  const submissions = [
    {
      title: 'Local Coffee Shop Raises $5,000 for Animal Shelter',
      description: 'A beloved downtown coffee shop organized a charity drive that successfully raised $5,000 for the city animal shelter. The community came together over the weekend to support our furry friends in need.',
      source_name: 'Demo Submission 1',
      source_url: 'https://example.com/coffee-charity',
      metro_id: DEMO_METRO,
      user_id: userId,
      status: 'pending',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      title: 'High School Students Launch Free Tutoring Program',
      description: 'A group of high school honor students started a volunteer tutoring program to help younger students with their homework. The program meets twice a week at the local library and has already helped 20 students improve their grades.',
      source_name: 'Demo Submission 2',
      source_url: 'https://example.com/tutoring-program',
      metro_id: DEMO_METRO,
      user_id: userId,
      status: 'pending',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    },
  ];

  for (const submission of submissions) {
    const docRef = await db.collection('submissions').add(submission);
    console.log(`   ✓ Created submission: ${submission.title}`);
    console.log(`     ID: ${docRef.id}`);
    console.log(`     Status: ${submission.status}`);
    console.log('');
  }

  console.log(`   ✅ Created ${submissions.length} demo submissions`);
  console.log('');
}

/**
 * Main execution
 */
async function main() {
  console.log('\n═══════════════════════════════════════════════════════════');
  console.log('  BrightSide Demo Reviewer Account Setup');
  console.log('═══════════════════════════════════════════════════════════');

  const args = process.argv.slice(2);
  const withSubmissions = args.includes('--with-submissions');

  try {
    // Create demo user
    const userId = await createDemoUser();

    // Optionally create submissions
    if (withSubmissions) {
      await createDemoSubmissions(userId);
    } else {
      console.log('   ℹ️  Skipping submissions (use --with-submissions to create them)\n');
    }

    // Print summary
    console.log('═══════════════════════════════════════════════════════════');
    console.log('  ✅ Demo Reviewer Account Ready!');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    console.log('Login Credentials:');
    console.log(`  Email:    ${DEMO_EMAIL}`);
    console.log(`  Password: ${DEMO_PASSWORD}`);
    console.log(`  Metro:    Salt Lake City (${DEMO_METRO})`);
    console.log('');

    if (withSubmissions) {
      console.log('Demo Submissions:');
      console.log('  • 2 pending submissions created');
      console.log('  • Visible in Admin Portal for testing moderation');
      console.log('');
    }

    console.log('Next Steps:');
    console.log('  1. Launch app and sign in with demo credentials');
    console.log('  2. View Today feed (should show SLC stories)');
    console.log('  3. Test Submit flow (should work)');
    console.log('  4. Test Popular feed (should show trending stories)');
    console.log('');

    console.log('For Admin Portal Access:');
    console.log('  1. Grant admin claim:');
    console.log(`     npx ts-node tool/admin_claims.ts grant ${DEMO_EMAIL}`);
    console.log('  2. Sign in again to refresh claims');
    console.log('  3. Navigate to Settings → Admin Portal');
    console.log('');

    console.log('═══════════════════════════════════════════════════════════');
    console.log('');

    process.exit(0);
  } catch (error: any) {
    console.error('\n❌ Failed to create demo reviewer account:', error.message);
    console.error('');
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('\n❌ Unexpected error:', error);
  process.exit(1);
});
