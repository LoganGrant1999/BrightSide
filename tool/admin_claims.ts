#!/usr/bin/env ts-node
/**
 * Admin Claims Management Script
 *
 * Grant or revoke admin custom claims for BrightSide users.
 *
 * Usage:
 *   npx ts-node tool/admin_claims.ts grant admin@example.com
 *   npx ts-node tool/admin_claims.ts revoke admin@example.com
 *
 * Environment:
 *   - Development: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npx ts-node tool/admin_claims.ts grant admin@example.com
 *   - Production: npx ts-node tool/admin_claims.ts grant admin@example.com
 */

import admin from 'firebase-admin';

// Initialize Firebase Admin
if (process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('🔧 Using Firebase Emulator');
  admin.initializeApp({ projectId: 'brightside-9a2c5' });
} else {
  admin.initializeApp({ projectId: 'brightside-9a2c5' });
}

const auth = admin.auth();

/**
 * Grant admin custom claim to a user
 */
async function grantAdmin(email: string): Promise<void> {
  console.log(`\n🔑 Granting admin role to: ${email}\n`);

  try {
    // Resolve email to UID
    const userRecord = await auth.getUserByEmail(email);
    const uid = userRecord.uid;

    console.log(`   ✓ Found user: ${email}`);
    console.log(`   ✓ UID: ${uid}`);

    // Set custom claims
    await auth.setCustomUserClaims(uid, { admin: true });

    console.log(`   ✓ Admin claim granted\n`);
    console.log('✅ Success! User is now an admin.\n');
    console.log('ℹ️  User must sign out and sign back in for changes to take effect.\n');

    // Verify claim was set
    const updatedUser = await auth.getUser(uid);
    console.log('Custom claims:', updatedUser.customClaims);
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      console.error(`\n❌ Error: User not found with email: ${email}`);
      console.error('   Make sure the user has signed up in the app first.\n');
    } else {
      console.error(`\n❌ Error granting admin claim:`, error.message);
    }
    process.exit(1);
  }
}

/**
 * Revoke admin custom claim from a user
 */
async function revokeAdmin(email: string): Promise<void> {
  console.log(`\n🔓 Revoking admin role from: ${email}\n`);

  try {
    // Resolve email to UID
    const userRecord = await auth.getUserByEmail(email);
    const uid = userRecord.uid;

    console.log(`   ✓ Found user: ${email}`);
    console.log(`   ✓ UID: ${uid}`);

    // Get current claims
    const currentClaims = userRecord.customClaims || {};

    if (!currentClaims.admin) {
      console.log(`\n⚠️  User ${email} does not have admin claim.\n`);
      process.exit(0);
    }

    // Remove admin claim by setting to null or removing from claims object
    const updatedClaims = { ...currentClaims };
    delete updatedClaims.admin;

    await auth.setCustomUserClaims(uid, Object.keys(updatedClaims).length > 0 ? updatedClaims : null);

    console.log(`   ✓ Admin claim revoked\n`);
    console.log('✅ Success! User is no longer an admin.\n');
    console.log('ℹ️  User must sign out and sign back in for changes to take effect.\n');

    // Verify claim was removed
    const updatedUser = await auth.getUser(uid);
    console.log('Custom claims:', updatedUser.customClaims || 'None');
  } catch (error: any) {
    if (error.code === 'auth/user-not-found') {
      console.error(`\n❌ Error: User not found with email: ${email}`);
      console.error('   Make sure the user has signed up in the app first.\n');
    } else {
      console.error(`\n❌ Error revoking admin claim:`, error.message);
    }
    process.exit(1);
  }
}

/**
 * List all admin users
 */
async function listAdmins(): Promise<void> {
  console.log('\n👥 Listing all admin users...\n');

  try {
    const listUsersResult = await auth.listUsers();
    const admins = listUsersResult.users.filter(
      (user) => user.customClaims && user.customClaims.admin === true
    );

    if (admins.length === 0) {
      console.log('   ℹ️  No admin users found.\n');
      return;
    }

    console.log(`   Found ${admins.length} admin(s):\n`);
    admins.forEach((admin) => {
      console.log(`   • ${admin.email || 'No email'} (${admin.uid})`);
    });
    console.log('');
  } catch (error: any) {
    console.error('\n❌ Error listing admins:', error.message);
    process.exit(1);
  }
}

/**
 * Main CLI entry point
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log(`
Admin Claims Management
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Usage:
  npx ts-node tool/admin_claims.ts <command> [email]

Commands:
  grant <email>    Grant admin role to user
  revoke <email>   Revoke admin role from user
  list             List all admin users

Examples:
  npx ts-node tool/admin_claims.ts grant admin@brightside.com
  npx ts-node tool/admin_claims.ts revoke user@example.com
  npx ts-node tool/admin_claims.ts list

Environment:
  Development (emulator):
    FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/admin_claims.ts grant admin@example.com

  Production:
    npx ts-node tool/admin_claims.ts grant admin@example.com
`);
    process.exit(1);
  }

  const command = args[0].toLowerCase();

  switch (command) {
    case 'grant':
      if (args.length < 2) {
        console.error('\n❌ Error: Email required for grant command\n');
        console.log('Usage: npx ts-node tool/admin_claims.ts grant <email>\n');
        process.exit(1);
      }
      await grantAdmin(args[1]);
      break;

    case 'revoke':
      if (args.length < 2) {
        console.error('\n❌ Error: Email required for revoke command\n');
        console.log('Usage: npx ts-node tool/admin_claims.ts revoke <email>\n');
        process.exit(1);
      }
      await revokeAdmin(args[1]);
      break;

    case 'list':
      await listAdmins();
      break;

    default:
      console.error(`\n❌ Error: Unknown command "${command}"\n`);
      console.log('Valid commands: grant, revoke, list\n');
      process.exit(1);
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('\n❌ Unexpected error:', error);
  process.exit(1);
});
