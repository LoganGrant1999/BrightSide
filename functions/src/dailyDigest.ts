import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

/**
 * Get top N articles for a metro from today's 5am rolling window
 */
export async function getTodayTopN(
  metroId: string,
  n: number = 3
): Promise<admin.firestore.DocumentSnapshot[]> {
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
function calculateFiveAmWindow(metroId: string): admin.firestore.Timestamp {
  // Metro timezone mappings
  const timezones: Record<string, string> = {
    slc: "America/Denver",
    nyc: "America/New_York",
    gsp: "America/New_York",
  };

  const timezone = timezones[metroId] || "America/Denver";
  const now = new Date();

  // Get current time in metro timezone
  const localTime = new Date(
    now.toLocaleString("en-US", {timeZone: timezone})
  );

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
export function buildPayload(
  metroId: string,
  articles: admin.firestore.DocumentSnapshot[]
): admin.messaging.Message {
  let title = "Your BrightSide stories are ready ☀️";
  let body = "Start your day with good news from your community";
  const dataPayload: Record<string, string> = {
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
  } else if (articles.length > 1) {
    // Multiple articles: route to Today tab
    const topArticle = articles[0].data();
    if (topArticle) {
      body = `${topArticle.title} • ${articles.length} stories today`;
    } else {
      body = `${articles.length} new positive stories from your area`;
    }
    dataPayload.route = "/today";
  } else {
    // No articles: route to Today tab
    dataPayload.route = "/today";
  }

  const message: admin.messaging.Message = {
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
export async function sendDigestToTopic(metroId: string): Promise<void> {
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

    logger.info(
      `Successfully sent digest to metro_${metroId}_daily topic. ` +
      `Message ID: ${response}, Articles: ${articles.length}`
    );
  } catch (error) {
    logger.error(`Failed to send digest for ${metroId}:`, error);
    throw error;
  }
}
