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
exports.getTodayTopN = getTodayTopN;
exports.buildPayload = buildPayload;
exports.sendDigestToTopic = sendDigestToTopic;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
/**
 * Get top N articles for a metro from today's 5am rolling window
 */
async function getTodayTopN(metroId, n = 3) {
    const db = admin.firestore();
    // Calculate 5am local window start time
    const windowStart = calculateFiveAmWindow(metroId);
    logger.info(`Getting top ${n} articles for ${metroId} since ${windowStart.toDate().toISOString()}`);
    const snapshot = await db
        .collection("articles")
        .where("metroId", "==", metroId)
        .where("status", "==", "published")
        .where("publishedAt", ">=", windowStart)
        .orderBy("publishedAt", "desc")
        .limit(n)
        .get();
    logger.info(`Found ${snapshot.docs.length} articles for ${metroId}`);
    return snapshot.docs;
}
/**
 * Calculate 5am local rolling window for a metro
 * If before 5am, returns 5am yesterday; otherwise 5am today
 */
function calculateFiveAmWindow(metroId) {
    // Metro timezone mappings
    const timezones = {
        slc: "America/Denver",
        nyc: "America/New_York",
        gsp: "America/New_York",
    };
    const timezone = timezones[metroId] || "America/Denver";
    const now = new Date();
    // Get current time in metro timezone
    const localTime = new Date(now.toLocaleString("en-US", { timeZone: timezone }));
    // Create 5am today in metro timezone
    const fiveAmToday = new Date(localTime);
    fiveAmToday.setHours(5, 0, 0, 0);
    // If current time is before 5am, use 5am yesterday
    let windowStart = fiveAmToday;
    if (localTime < fiveAmToday) {
        windowStart = new Date(fiveAmToday);
        windowStart.setDate(windowStart.getDate() - 1);
    }
    return admin.firestore.Timestamp.fromDate(windowStart);
}
/**
 * Build FCM notification payload from articles
 * - Single article: includes articleId, routes to article detail
 * - Multiple articles: routes to /today, no articleId
 */
function buildPayload(metroId, articles) {
    let title = "Your BrightSide stories are ready ☀️";
    let body = "Start your day with good news from your community";
    const dataPayload = {
        metroId,
        type: "daily_digest",
    };
    if (articles.length === 1) {
        // Single article: route to article detail
        const article = articles[0].data();
        if (article) {
            title = "New positive story ☀️";
            body = article.title || "New positive story from your area";
            dataPayload.articleId = articles[0].id;
            dataPayload.route = "/article";
        }
    }
    else if (articles.length > 1) {
        // Multiple articles: route to Today tab
        const topArticle = articles[0].data();
        if (topArticle) {
            body = `${topArticle.title} • ${articles.length} stories today`;
        }
        else {
            body = `${articles.length} new positive stories from your area`;
        }
        dataPayload.route = "/today";
    }
    else {
        // No articles: route to Today tab
        dataPayload.route = "/today";
    }
    const message = {
        topic: `metro_${metroId}_daily`,
        notification: {
            title,
            body,
        },
        data: dataPayload,
        apns: {
            payload: {
                aps: {
                    sound: "default",
                    badge: 1,
                },
            },
        },
        android: {
            priority: "high",
            notification: {
                channelId: "daily_digest",
                priority: "high",
                defaultSound: true,
            },
        },
    };
    return message;
}
/**
 * Send daily digest to metro topic
 * Only sends if there are articles available
 */
async function sendDigestToTopic(metroId) {
    logger.info(`Starting daily digest for metro: ${metroId}`);
    try {
        // Get top 3 articles
        const articles = await getTodayTopN(metroId, 3);
        if (articles.length === 0) {
            logger.warn(`No articles found for ${metroId}, skipping digest`);
            return;
        }
        // Build notification payload
        const message = buildPayload(metroId, articles);
        // Send to FCM topic
        const response = await admin.messaging().send(message);
        logger.info(`Successfully sent digest to metro_${metroId}_daily topic. ` +
            `Message ID: ${response}, Articles: ${articles.length}`);
    }
    catch (error) {
        logger.error(`Failed to send digest for ${metroId}:`, error);
        throw error;
    }
}
//# sourceMappingURL=dailyDigest.js.map