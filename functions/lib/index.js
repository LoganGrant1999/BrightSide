"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.promoteSubmission = exports.rotateFeaturedDaily = exports.onLikeDeleted = exports.onLikeCreated = exports.testIngest = exports.sendTestPush = exports.sendTestDigest = exports.gspDailyDigest = exports.nycDailyDigest = exports.slcDailyDigest = exports.featureArticle = exports.rejectSubmission = exports.approveSubmission = exports.rotateFeaturedGsp = exports.rotateFeaturedNyc = exports.rotateFeaturedSlc = exports.digestGsp = exports.digestNyc = exports.digestSlc = exports.ingestGsp = exports.ingestNyc = exports.ingestSlc = exports.deleteAccount = void 0;
const admin = __importStar(require("firebase-admin"));
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const https_1 = require("firebase-functions/v2/https");
const admin_1 = require("./admin");
const time_1 = require("./utils/time");
// Export deleteAccount callable function
var deleteAccount_1 = require("./deleteAccount");
Object.defineProperty(exports, "deleteAccount", { enumerable: true, get: function () { return deleteAccount_1.deleteAccount; } });
// Export scheduled ingestion functions
var schedules_1 = require("./schedules");
Object.defineProperty(exports, "ingestSlc", { enumerable: true, get: function () { return schedules_1.ingestSlc; } });
Object.defineProperty(exports, "ingestNyc", { enumerable: true, get: function () { return schedules_1.ingestNyc; } });
Object.defineProperty(exports, "ingestGsp", { enumerable: true, get: function () { return schedules_1.ingestGsp; } });
// Export scheduled digest functions
var schedules_2 = require("./schedules");
Object.defineProperty(exports, "digestSlc", { enumerable: true, get: function () { return schedules_2.digestSlc; } });
Object.defineProperty(exports, "digestNyc", { enumerable: true, get: function () { return schedules_2.digestNyc; } });
Object.defineProperty(exports, "digestGsp", { enumerable: true, get: function () { return schedules_2.digestGsp; } });
// Export scheduled featured rotation functions
var schedules_3 = require("./schedules");
Object.defineProperty(exports, "rotateFeaturedSlc", { enumerable: true, get: function () { return schedules_3.rotateFeaturedSlc; } });
Object.defineProperty(exports, "rotateFeaturedNyc", { enumerable: true, get: function () { return schedules_3.rotateFeaturedNyc; } });
Object.defineProperty(exports, "rotateFeaturedGsp", { enumerable: true, get: function () { return schedules_3.rotateFeaturedGsp; } });
// Export moderation callable functions
var moderation_1 = require("./moderation");
Object.defineProperty(exports, "approveSubmission", { enumerable: true, get: function () { return moderation_1.approveSubmission; } });
Object.defineProperty(exports, "rejectSubmission", { enumerable: true, get: function () { return moderation_1.rejectSubmission; } });
// Export feature article callable function
var featureArticle_1 = require("./featureArticle");
Object.defineProperty(exports, "featureArticle", { enumerable: true, get: function () { return featureArticle_1.featureArticle; } });
// Export notification functions (legacy v1 schedulers)
var notifications_1 = require("./notifications");
Object.defineProperty(exports, "slcDailyDigest", { enumerable: true, get: function () { return notifications_1.slcDailyDigest; } });
Object.defineProperty(exports, "nycDailyDigest", { enumerable: true, get: function () { return notifications_1.nycDailyDigest; } });
Object.defineProperty(exports, "gspDailyDigest", { enumerable: true, get: function () { return notifications_1.gspDailyDigest; } });
Object.defineProperty(exports, "sendTestDigest", { enumerable: true, get: function () { return notifications_1.sendTestDigest; } });
// Export test push notification function
var sendTestPush_1 = require("./notifications/sendTestPush");
Object.defineProperty(exports, "sendTestPush", { enumerable: true, get: function () { return sendTestPush_1.sendTestPush; } });
// Export test ingestion HTTP function
var testIngest_1 = require("./testIngest");
Object.defineProperty(exports, "testIngest", { enumerable: true, get: function () { return testIngest_1.testIngest; } });
admin.initializeApp();
const db = admin.firestore();
/**
 * Trigger: onCreate /articleLikes/{likeId}
 * Increments article like counts (total and 24h)
 */
exports.onLikeCreated = (0, firestore_1.onDocumentCreated)("articleLikes/{likeId}", async (event) => {
    const likeData = event.data?.data();
    if (!likeData)
        return;
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
});
/**
 * Trigger: onDelete /articleLikes/{likeId}
 * Decrements article like counts (total and 24h)
 */
exports.onLikeDeleted = (0, firestore_1.onDocumentDeleted)("articleLikes/{likeId}", async (event) => {
    const likeData = event.data?.data();
    if (!likeData)
        return;
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
});
/**
 * Scheduled: Daily at 05:00 America/Denver (12:00 UTC)
 * Rotates featured articles per metro
 */
exports.rotateFeaturedDaily = (0, scheduler_1.onSchedule)({
    schedule: "0 12 * * *", // 12:00 UTC = 05:00 MST/MDT
    timeZone: "UTC",
}, async () => {
    functions.logger.info("Starting daily featured article rotation");
    const metros = ["slc", "nyc", "gsp"];
    const now = admin.firestore.Timestamp.now();
    const lookbackTime = admin.firestore.Timestamp.fromDate((0, time_1.get24HoursAgo)());
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
        }
        catch (error) {
            functions.logger.error(`Error rotating featured for ${metroId}:`, error);
        }
    }
    functions.logger.info("Completed daily featured article rotation");
});
/**
 * Callable: promoteSubmission
 * Admin-only function to promote approved submission to published article
 */
exports.promoteSubmission = (0, https_1.onCall)(async (request) => {
    // Check admin auth
    if (!(0, admin_1.isAdmin)(request.auth)) {
        throw new https_1.HttpsError("permission-denied", "Only admins can promote submissions");
    }
    const { submissionId } = request.data;
    if (!submissionId || typeof submissionId !== "string") {
        throw new https_1.HttpsError("invalid-argument", "submissionId is required");
    }
    const submissionRef = db.collection("submissions").doc(submissionId);
    const submissionDoc = await submissionRef.get();
    if (!submissionDoc.exists) {
        throw new https_1.HttpsError("not-found", `Submission ${submissionId} not found`);
    }
    const submission = submissionDoc.data();
    if (submission.status !== "pending") {
        throw new https_1.HttpsError("failed-precondition", `Submission status is ${submission.status}, expected pending`);
    }
    // Create new article from submission
    const now = admin.firestore.Timestamp.now();
    const articleData = {
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
});
//# sourceMappingURL=index.js.map