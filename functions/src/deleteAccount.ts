import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const auth = admin.auth();

/**
 * Callable function: Delete user account and all associated data
 *
 * Security:
 * - Requires authentication
 * - Users can only delete their own account (non-admin)
 *
 * Deletes:
 * - User's Auth record
 * - users/{uid} document
 * - users/{uid}/devices subcollection
 * - articleLikes where user_id == uid
 * - submissions where user_id == uid
 * - Optionally redacts analytics identifiers
 *
 * @param data - Empty object (uses context.auth.uid)
 * @param context - Callable function context with auth info
 */
export const deleteAccount = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be authenticated to delete account"
    );
  }

  const uid = context.auth.uid;

  console.log(`Starting account deletion for user: ${uid}`);

  try {
    // Step 1: Revoke refresh tokens to immediately invalidate sessions
    await auth.revokeRefreshTokens(uid);
    console.log(`Revoked refresh tokens for user: ${uid}`);

    // Step 2: Delete devices subcollection
    await deleteSubcollection(`users/${uid}/devices`, 100);
    console.log(`Deleted devices subcollection for user: ${uid}`);

    // Step 3: Delete article likes
    await deleteDocumentsWhere("articleLikes", "user_id", uid, 100);
    console.log(`Deleted article likes for user: ${uid}`);

    // Step 4: Delete user submissions
    await deleteDocumentsWhere("submissions", "user_id", uid, 100);
    console.log(`Deleted submissions for user: ${uid}`);

    // Step 5: Redact analytics (optional - set user_id to 'deleted')
    await redactAnalytics(uid);
    console.log(`Redacted analytics for user: ${uid}`);

    // Step 6: Delete user document
    await db.collection("users").doc(uid).delete();
    console.log(`Deleted user document for user: ${uid}`);

    // Step 7: Delete Firebase Auth user (MUST BE LAST)
    await auth.deleteUser(uid);
    console.log(`Deleted auth record for user: ${uid}`);

    // Log deletion event
    await logAccountDeletion(uid);

    return {
      success: true,
      message: "Account and all associated data deleted successfully",
    };
  } catch (error) {
    console.error(`Error deleting account for user ${uid}:`, error);
    throw new functions.https.HttpsError(
      "internal",
      `Failed to delete account: ${error}`
    );
  }
});

/**
 * Delete a subcollection in batches
 */
async function deleteSubcollection(
  collectionPath: string,
  batchSize: number
): Promise<void> {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve, reject);
  });
}

/**
 * Delete documents matching a where clause in batches
 */
async function deleteDocumentsWhere(
  collectionName: string,
  field: string,
  value: string,
  batchSize: number
): Promise<void> {
  const query = db
    .collection(collectionName)
    .where(field, "==", value)
    .limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve, reject);
  });
}

/**
 * Recursively delete documents in batches
 */
function deleteQueryBatch(
  query: admin.firestore.Query,
  resolve: () => void,
  reject: (error: Error) => void
): void {
  query
    .get()
    .then((snapshot) => {
      // When there are no documents left, we are done
      if (snapshot.size === 0) {
        resolve();
        return;
      }

      // Delete documents in a batch
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      return batch.commit().then(() => {
        return snapshot.size;
      });
    })
    .then((numDeleted) => {
      if (numDeleted === 0) {
        resolve();
        return;
      }

      // Recurse on the next batch
      process.nextTick(() => {
        deleteQueryBatch(query, resolve, reject);
      });
    })
    .catch(reject);
}

/**
 * Redact analytics by setting user_id to 'deleted'
 * This preserves analytics data while anonymizing it
 */
async function redactAnalytics(uid: string): Promise<void> {
  const analyticsRef = db.collection("analytics").where("user_id", "==", uid);
  const snapshot = await analyticsRef.get();

  if (snapshot.empty) {
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.update(doc.ref, {
      user_id: "deleted",
      redacted_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
}

/**
 * Log account deletion for audit trail
 */
async function logAccountDeletion(uid: string): Promise<void> {
  try {
    await db.collection("deletedAccounts").add({
      uid,
      deleted_at: admin.firestore.FieldValue.serverTimestamp(),
      deleted_by: "user", // vs "admin" if admin-initiated
    });
  } catch (error) {
    console.error("Error logging account deletion:", error);
    // Don't throw - logging failure shouldn't stop deletion
  }
}
