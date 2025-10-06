import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/**
 * Rotate featured articles daily
 * - Selects top articles by like_count from the past 7 days
 * - Skips manually pinned articles (featured_end == null AND is_featured == true)
 * - Unfeatures old auto-featured items
 * - Features new top articles with 24h duration
 *
 * Called by schedulers (rotateFeaturedSlc, rotateFeaturedNyc, rotateFeaturedGsp)
 */
export async function rotateFeatured(metroId: string): Promise<number> {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  const sevenDaysAgoTimestamp = admin.firestore.Timestamp.fromDate(sevenDaysAgo);

  logger.info(`Starting featured rotation for ${metroId}`);

  try {
    // Step 1: Unfeature expired auto-featured items (where featured_end <= now)
    const expiredQuery = await db
      .collection("articles")
      .where("metro_id", "==", metroId)
      .where("is_featured", "==", true)
      .where("featured_end", "!=", null)
      .where("featured_end", "<=", now)
      .get();

    const batch1 = db.batch();
    expiredQuery.docs.forEach((doc) => {
      batch1.update(doc.ref, {
        is_featured: false,
      });
    });

    if (!expiredQuery.empty) {
      await batch1.commit();
      logger.info(`Unfeatured ${expiredQuery.size} expired articles for ${metroId}`);
    }

    // Step 2: Count currently featured items (including manual pins)
    const currentlyFeaturedQuery = await db
      .collection("articles")
      .where("metro_id", "==", metroId)
      .where("is_featured", "==", true)
      .get();

    const currentlyFeaturedCount = currentlyFeaturedQuery.size;
    logger.info(`Currently featured: ${currentlyFeaturedCount} articles for ${metroId}`);

    // Step 3: Calculate how many new articles to feature
    const targetFeaturedCount = 3; // Feature 3 articles total
    const slotsAvailable = Math.max(0, targetFeaturedCount - currentlyFeaturedCount);

    if (slotsAvailable === 0) {
      logger.info(`No slots available for ${metroId}, rotation complete`);
      return 0;
    }

    logger.info(`${slotsAvailable} slots available for ${metroId}`);

    // Step 4: Find top articles from past 7 days that aren't already featured
    const candidatesQuery = await db
      .collection("articles")
      .where("metro_id", "==", metroId)
      .where("status", "==", "published")
      .where("is_featured", "==", false)
      .where("publish_time", ">=", sevenDaysAgoTimestamp)
      .orderBy("publish_time", "desc")
      .orderBy("like_count", "desc")
      .limit(slotsAvailable * 3) // Get more candidates to ensure quality
      .get();

    if (candidatesQuery.empty) {
      logger.warn(`No candidate articles found for ${metroId}`);
      return 0;
    }

    // Sort candidates by like_count descending and take top N
    const candidates = candidatesQuery.docs
      .map((doc) => ({
        ref: doc.ref,
        like_count: doc.data().like_count || 0,
      }))
      .sort((a, b) => b.like_count - a.like_count)
      .slice(0, slotsAvailable);

    // Step 5: Feature the top candidates with 24h duration
    const batch2 = db.batch();
    const oneDayLater = new Date(now.toDate());
    oneDayLater.setDate(oneDayLater.getDate() + 1);
    const featuredEnd = admin.firestore.Timestamp.fromDate(oneDayLater);

    candidates.forEach((candidate) => {
      batch2.update(candidate.ref, {
        is_featured: true,
        featured_start: now,
        featured_end: featuredEnd,
      });
    });

    await batch2.commit();

    logger.info(`Featured ${candidates.length} new articles for ${metroId}`, {
      featured_start: now,
      featured_end: featuredEnd,
    });

    return candidates.length;
  } catch (error) {
    logger.error(`Featured rotation failed for ${metroId}:`, error);
    throw error;
  }
}
