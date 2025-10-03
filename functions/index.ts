import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {onCall} from 'firebase-functions/v2/https';
import {onSchedule} from 'firebase-functions/v2/scheduler';

admin.initializeApp();

const db = admin.firestore();

/**
 * Like an article
 * Validates auth, checks article is not featured, atomically creates like record and increments count
 */
export const likeArticle = onCall(async (request) => {
  // Validate authentication
  if (!request.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to like articles'
    );
  }

  const {storyId} = request.data;
  const uid = request.auth.uid;

  if (!storyId || typeof storyId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'storyId is required and must be a string'
    );
  }

  // Read article to validate it exists and is not featured
  const articleRef = db.collection('articles').doc(storyId);
  const articleSnap = await articleRef.get();

  if (!articleSnap.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      'Article not found'
    );
  }

  const articleData = articleSnap.data();
  if (articleData?.featured === true) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Featured articles cannot be liked'
    );
  }

  // Create like document atomically
  const likeId = `${storyId}_${uid}`;
  const likeRef = db.collection('articleLikes').doc(likeId);

  try {
    await db.runTransaction(async (transaction) => {
      const likeSnap = await transaction.get(likeRef);

      if (likeSnap.exists) {
        // Already liked, remove the like (unlike)
        transaction.delete(likeRef);
        transaction.update(articleRef, {
          likeCount: admin.firestore.FieldValue.increment(-1),
        });
      } else {
        // Create new like
        transaction.set(likeRef, {
          uid,
          articleId: storyId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        transaction.update(articleRef, {
          likeCount: admin.firestore.FieldValue.increment(1),
        });
      }
    });

    // Return the updated like count
    const updatedArticle = await articleRef.get();
    const likeCount = updatedArticle.data()?.likeCount ?? 0;

    return {likeCount};
  } catch (error) {
    console.error('Error toggling like:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to toggle like'
    );
  }
});

/**
 * Admin-only: Fix seed data for a metro
 * Ensures articles have proper status, featured flag, and recent publishedAt
 */
export const fixSeedForMetro = onCall(async (request) => {
  // Validate authentication
  if (!request.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Auth required'
    );
  }

  // Validate token
  const token = request.data?.token as string | undefined;
  const expected = process.env.FIX_SEED_TOKEN || functions.config().admin?.fix_seed_token;
  if (!token || token !== expected) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Invalid token'
    );
  }

  // Validate and parse inputs
  const metroId = (request.data?.metroId as string || '').trim();
  const limit = Math.min(Math.max(Number(request.data?.limit || 25), 1), 100);

  if (!metroId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'metroId is required'
    );
  }

  // Query articles for this metro
  const snap = await db
    .collection('articles')
    .where('metroId', '==', metroId)
    .limit(limit)
    .get();

  let updated = 0;
  const batch = db.batch();
  const nowMinus7d = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  );

  snap.forEach((doc) => {
    const d = doc.data() || {};
    const needsStatus = d.status !== 'published';
    const needsFeatured = typeof d.featured !== 'boolean';
    const missingOrOldPublishedAt =
      !d.publishedAt ||
      !(d.publishedAt instanceof admin.firestore.Timestamp) ||
      (d.publishedAt.seconds < nowMinus7d.seconds);

    if (needsStatus || needsFeatured || missingOrOldPublishedAt) {
      const upd: Record<string, any> = {};
      if (needsStatus) upd.status = 'published';
      if (needsFeatured) upd.featured = false;
      if (missingOrOldPublishedAt) {
        upd.publishedAt = admin.firestore.FieldValue.serverTimestamp();
      }
      batch.update(doc.ref, upd);
      updated++;
    }
  });

  if (updated > 0) await batch.commit();

  console.log(`Fixed ${updated} articles for metro ${metroId}`);
  return {updatedCount: updated};
});

/**
 * Rotate featured articles daily
 * Runs at 00:05 UTC every day, computes top 5 articles per metro from last 30 days
 */
export const rotateFeaturedDaily = onSchedule('every day 00:05', async () => {
  const metros = ['slc', 'nyc', 'gsp'];
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.now - 30);

  for (const metroId of metros) {
    try {
      // Query last 30 days articles for this metro
      const articlesSnap = await db
        .collection('articles')
        .where('metroId', '==', metroId)
        .where('status', '==', 'published')
        .where('publishedAt', '>=', thirtyDaysAgo)
        .orderBy('publishedAt', 'desc')
        .orderBy('likeCount', 'desc')
        .limit(5)
        .get();

      // Clear existing featured for this metro
      const existingFeaturedSnap = await db
        .collection('articles')
        .where('metroId', '==', metroId)
        .where('featured', '==', true)
        .get();

      const batch = db.batch();

      // Unflag existing featured articles
      existingFeaturedSnap.forEach((doc) => {
        batch.update(doc.ref, {
          featured: false,
          featuredAt: null,
        });
      });

      // Flag new top 5 as featured
      const now = admin.firestore.FieldValue.serverTimestamp();
      articlesSnap.forEach((doc) => {
        batch.update(doc.ref, {
          featured: true,
          featuredAt: now,
        });
      });

      await batch.commit();

      console.log(`Rotated featured articles for ${metroId}: ${articlesSnap.size} articles`);
    } catch (error) {
      console.error(`Error rotating featured for ${metroId}:`, error);
    }
  }
});
