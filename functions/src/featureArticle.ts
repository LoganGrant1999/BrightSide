import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/**
 * Feature or unfeature an article
 * Admins can manually pin articles that persist until unfeatured
 *
 * Manual pins: is_featured=true, featured_start=now, featured_end=null
 * Unfeature: is_featured=false, featured_end=now
 */
export const featureArticle = onCall(async (request) => {
  const uid = request.auth?.uid;
  const {articleId, feature, endAt} = request.data;

  // Check authentication
  if (!uid) {
    throw new HttpsError("unauthenticated", "User must be signed in");
  }

  // Verify admin claim
  const userRecord = await admin.auth().getUser(uid);
  if (userRecord.customClaims?.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "Only admins can feature articles"
    );
  }

  // Validate inputs
  if (!articleId || typeof articleId !== "string") {
    throw new HttpsError("invalid-argument", "articleId is required");
  }

  if (typeof feature !== "boolean") {
    throw new HttpsError("invalid-argument", "feature must be boolean");
  }

  const db = admin.firestore();
  const articleRef = db.collection("articles").doc(articleId);

  try {
    const articleDoc = await articleRef.get();

    if (!articleDoc.exists) {
      throw new HttpsError("not-found", "Article not found");
    }

    const now = admin.firestore.Timestamp.now();
    const updates: Record<string, any> = {};

    if (feature) {
      // Feature the article (manual pin)
      updates.is_featured = true;
      updates.featured_start = now;

      // If endAt is provided (timestamp in ms), use it; otherwise null for manual pin
      if (endAt && typeof endAt === "number") {
        updates.featured_end = admin.firestore.Timestamp.fromMillis(endAt);
      } else {
        updates.featured_end = null;
      }

      logger.info(`Featuring article ${articleId}`, {
        uid,
        featured_start: now,
        featured_end: updates.featured_end,
      });
    } else {
      // Unfeature the article
      updates.is_featured = false;
      updates.featured_end = now;

      logger.info(`Unfeaturing article ${articleId}`, {
        uid,
        featured_end: now,
      });
    }

    await articleRef.update(updates);

    return {
      success: true,
      articleId,
      is_featured: updates.is_featured,
    };
  } catch (error: any) {
    logger.error("Feature article error:", error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
      "internal",
      `Failed to update article: ${error.message}`
    );
  }
});
