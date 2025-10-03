import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { onDocumentCreated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { isAdmin } from "./admin";
import { get24HoursAgo } from "./utils/time";
import { Article, Submission } from "./types";

admin.initializeApp();
const db = admin.firestore();

/**
 * Trigger: onCreate /articleLikes/{likeId}
 * Increments article like counts (total and 24h)
 */
export const onLikeCreated = onDocumentCreated(
  "articleLikes/{likeId}",
  async (event) => {
    const likeData = event.data?.data();
    if (!likeData) return;

    const articleId = likeData.article_id;
    const articleRef = db.collection("articles").doc(articleId);

    await db.runTransaction(async (transaction) => {
      const articleDoc = await transaction.get(articleRef);
      if (!articleDoc.exists) {
        throw new Error(`Article ${articleId} not found`);
      }

      const currentTotal = articleDoc.data()?.like_count_total || 0;
      const current24h = articleDoc.data()?.like_count_24h || 0;

      transaction.update(articleRef, {
        like_count_total: currentTotal + 1,
        like_count_24h: current24h + 1,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info(`Incremented likes for article ${articleId}`);
  }
);

/**
 * Trigger: onDelete /articleLikes/{likeId}
 * Decrements article like counts (total and 24h)
 */
export const onLikeDeleted = onDocumentDeleted(
  "articleLikes/{likeId}",
  async (event) => {
    const likeData = event.data?.data();
    if (!likeData) return;

    const articleId = likeData.article_id;
    const articleRef = db.collection("articles").doc(articleId);

    await db.runTransaction(async (transaction) => {
      const articleDoc = await transaction.get(articleRef);
      if (!articleDoc.exists) {
        functions.logger.warn(`Article ${articleId} not found for like deletion`);
        return;
      }

      const currentTotal = articleDoc.data()?.like_count_total || 0;
      const current24h = articleDoc.data()?.like_count_24h || 0;

      transaction.update(articleRef, {
        like_count_total: Math.max(0, currentTotal - 1),
        like_count_24h: Math.max(0, current24h - 1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info(`Decremented likes for article ${articleId}`);
  }
);

/**
 * Scheduled: Daily at 05:00 America/Denver (12:00 UTC)
 * Rotates featured articles per metro
 */
export const rotateFeaturedDaily = onSchedule(
  {
    schedule: "0 12 * * *", // 12:00 UTC = 05:00 MST/MDT
    timeZone: "UTC",
  },
  async () => {
    functions.logger.info("Starting daily featured article rotation");

    const metros = ["slc", "nyc", "gsp"];
    const now = admin.firestore.Timestamp.now();
    const lookbackTime = admin.firestore.Timestamp.fromDate(get24HoursAgo());

    for (const metroId of metros) {
      try {
        // Clear old featured articles for this metro
        const oldFeaturedQuery = db
          .collection("articles")
          .where("metro_id", "==", metroId)
          .where("is_featured", "==", true);

        const oldFeaturedSnapshot = await oldFeaturedQuery.get();
        const batch = db.batch();

        oldFeaturedSnapshot.docs.forEach((doc) => {
          batch.update(doc.ref, {
            is_featured: false,
            featured_start: null,
            featured_end: null,
            updated_at: now,
          });
        });

        // Get top 5 articles by likes in last 24h
        const topArticlesQuery = db
          .collection("articles")
          .where("metro_id", "==", metroId)
          .where("status", "==", "published")
          .where("publish_time", ">=", lookbackTime)
          .orderBy("publish_time", "desc")
          .orderBy("like_count_24h", "desc")
          .limit(5);

        const topArticlesSnapshot = await topArticlesQuery.get();

        topArticlesSnapshot.docs.forEach((doc) => {
          const featuredEnd = new Date(now.toDate());
          featuredEnd.setDate(featuredEnd.getDate() + 1);

          batch.update(doc.ref, {
            is_featured: true,
            featured_start: now,
            featured_end: admin.firestore.Timestamp.fromDate(featuredEnd),
            updated_at: now,
          });
        });

        await batch.commit();
        functions.logger.info(`Rotated featured articles for ${metroId}: ${topArticlesSnapshot.size} articles`);
      } catch (error) {
        functions.logger.error(`Error rotating featured for ${metroId}:`, error);
      }
    }

    functions.logger.info("Completed daily featured article rotation");
  }
);

/**
 * Callable: promoteSubmission
 * Admin-only function to promote approved submission to published article
 */
export const promoteSubmission = onCall(
  async (request) => {
    // Check admin auth
    if (!isAdmin(request.auth as any)) {
      throw new HttpsError(
        "permission-denied",
        "Only admins can promote submissions"
      );
    }

    const { submissionId } = request.data;
    if (!submissionId || typeof submissionId !== "string") {
      throw new HttpsError("invalid-argument", "submissionId is required");
    }

    const submissionRef = db.collection("submissions").doc(submissionId);
    const submissionDoc = await submissionRef.get();

    if (!submissionDoc.exists) {
      throw new HttpsError("not-found", `Submission ${submissionId} not found`);
    }

    const submission = submissionDoc.data() as Submission;

    if (submission.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        `Submission status is ${submission.status}, expected pending`
      );
    }

    // Create new article from submission
    const now = admin.firestore.Timestamp.now();
    const articleData: Partial<Article> = {
      title: submission.title,
      summary: submission.summary,
      source_name: submission.source_name || "User Submission",
      source_url: submission.source_url || "",
      image_url: submission.image_url || "",
      metro_id: submission.metro_id,
      status: "published",
      publish_time: now,
      is_featured: false,
      featured_start: null,
      featured_end: null,
      like_count_total: 0,
      like_count_24h: 0,
      hot_score: 0,
      created_at: now,
      updated_at: now,
    };

    const articleRef = await db.collection("articles").add(articleData);

    // Update submission with approval info
    await submissionRef.update({
      status: "approved",
      approved_article_id: articleRef.id,
      moderator_id: request.auth?.uid,
      updated_at: now,
    });

    functions.logger.info(`Promoted submission ${submissionId} to article ${articleRef.id}`);

    return {
      success: true,
      articleId: articleRef.id,
    };
  }
);
