/**
 * Set admin custom claim for a user
 *
 * Usage:
 *   node set_admin_claim.js <USER_UID>
 *
 * For emulator testing:
 *   FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" FIREBASE_AUTH_EMULATOR_HOST="127.0.0.1:9099" node set_admin_claim.js <USER_UID>
 */

const admin = require('firebase-admin');

// Check for emulator environment variables
const isEmulator = process.env.FIRESTORE_EMULATOR_HOST || process.env.FIREBASE_AUTH_EMULATOR_HOST;

if (isEmulator) {
  console.log('📡 Using Firebase Emulator');
  console.log(`   Auth: ${process.env.FIREBASE_AUTH_EMULATOR_HOST || 'not set'}`);
  console.log(`   Firestore: ${process.env.FIRESTORE_EMULATOR_HOST || 'not set'}`);
  admin.initializeApp({ projectId: 'brightside-test' });
} else {
  console.log('☁️  Using Production Firebase');
  admin.initializeApp();
}

async function setAdminClaim(uid) {
  try {
    // Set custom claim
    await admin.auth().setCustomUserClaims(uid, { admin: true });
    console.log(`\n✅ Admin claim set for user: ${uid}`);

    // Verify it was set
    const user = await admin.auth().getUser(uid);
    console.log('\n📋 User custom claims:');
    console.log(JSON.stringify(user.customClaims, null, 2));

    console.log('\n⚠️  Important: User must sign out and sign back in for claims to take effect\n');
  } catch (error) {
    console.error('\n❌ Error setting admin claim:', error.message);
    process.exit(1);
  }
}

// Get UID from command line argument
const uid = process.argv[2];

if (!uid) {
  console.error('\n❌ Usage: node set_admin_claim.js <USER_UID>\n');
  process.exit(1);
}

setAdminClaim(uid)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Script error:', error);
    process.exit(1);
  });
