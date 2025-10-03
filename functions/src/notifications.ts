import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Send daily digest notification to a metro topic
 * @param metroId - Metro ID (slc, nyc, or gsp)
 */
export async function sendMetroDaily(
  metroId: "slc" | "nyc" | "gsp"
): Promise<void> {
  console.log(`Sending daily digest for metro: ${metroId}`);

  try {
    // Get metro info
    const metroDoc = await db.collection("metros").doc(metroId).get();
    if (!metroDoc.exists) {
      console.error(`Metro ${metroId} not found`);
      return;
    }

    const metro = metroDoc.data();
    const metroName = metro?.name || metroId.toUpperCase();

    // Query up to 5 published articles from last 24 hours
    const oneDayAgo = new Date();
    oneDayAgo.setHours(oneDayAgo.getHours() - 24);

    const articlesSnapshot = await db
      .collection("articles")
      .where("metro_id", "==", metroId)
      .where("status", "==", "published")
      .where("publish_time", ">=", admin.firestore.Timestamp.fromDate(oneDayAgo))
      .orderBy("publish_time", "desc")
      .limit(5)
      .get();

    if (articlesSnapshot.empty) {
      console.log(`No articles found for metro ${metroId}`);
      // Still send notification with generic message
      await sendGenericDigest(metroId, metroName);
      return;
    }

    const articles = articlesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // Build notification title and body
    const articleCount = articles.length;
    const title = `🌟 Good Morning, ${metroName}!`;
    const body =
      articleCount === 1
        ? articles[0].title
        : `${articleCount} positive stories from your community today`;

    // Build notification payload
    const message: admin.messaging.Message = {
      topic: `metro_${metroId}_daily`,
      notification: {
        title,
        body,
      },
      data: {
        metro_id: metroId,
        type: "daily_digest",
        article_count: articleCount.toString(),
        route: "/today", // Deep link to Today feed
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send notification
    const response = await messaging.send(message);
    console.log(
      `Daily digest sent to metro_${metroId}_daily. Message ID: ${response}`
    );

    // Log analytics event
    await logDigestSent(metroId, articleCount);
  } catch (error) {
    console.error(`Error sending daily digest for ${metroId}:`, error);
    throw error;
  }
}

/**
 * Send generic digest when no articles are available
 */
async function sendGenericDigest(
  metroId: string,
  metroName: string
): Promise<void> {
  const message: admin.messaging.Message = {
    topic: `metro_${metroId}_daily`,
    notification: {
      title: `Good Morning, ${metroName}!`,
      body: "Check back later for today's positive news",
    },
    data: {
      metro_id: metroId,
      type: "daily_digest",
      article_count: "0",
      route: "/today",
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  await messaging.send(message);
  console.log(`Generic digest sent to metro_${metroId}_daily`);
}

/**
 * Log analytics for digest sent
 */
async function logDigestSent(
  metroId: string,
  articleCount: number
): Promise<void> {
  try {
    await db.collection("analytics").add({
      event: "daily_digest_sent",
      metro_id: metroId,
      article_count: articleCount,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error("Error logging analytics:", error);
    // Don't throw - analytics failure shouldn't stop digest
  }
}

/**
 * Scheduled function: Send daily digest for Salt Lake City (7 AM Mountain Time)
 */
export const slcDailyDigest = functions.pubsub
  .schedule("0 7 * * *")
  .timeZone("America/Denver")
  .onRun(async (context) => {
    await sendMetroDaily("slc");
  });

/**
 * Scheduled function: Send daily digest for New York City (7 AM Eastern Time)
 */
export const nycDailyDigest = functions.pubsub
  .schedule("0 7 * * *")
  .timeZone("America/New_York")
  .onRun(async (context) => {
    await sendMetroDaily("nyc");
  });

/**
 * Scheduled function: Send daily digest for Greenville-Spartanburg (7 AM Eastern Time)
 */
export const gspDailyDigest = functions.pubsub
  .schedule("0 7 * * *")
  .timeZone("America/New_York")
  .onRun(async (context) => {
    await sendMetroDaily("gsp");
  });

/**
 * HTTP function: Manual trigger for testing
 * Usage: POST /sendTestDigest with body { "metroId": "slc" }
 */
export const sendTestDigest = functions.https.onRequest(async (req, res) => {
  const metroId = req.body.metroId || req.query.metroId;

  if (!["slc", "nyc", "gsp"].includes(metroId)) {
    res.status(400).send("Invalid metroId. Must be slc, nyc, or gsp");
    return;
  }

  try {
    await sendMetroDaily(metroId as "slc" | "nyc" | "gsp");
    res.status(200).send(`Daily digest sent for ${metroId}`);
  } catch (error) {
    console.error(error);
    res.status(500).send(`Error sending digest: ${error}`);
  }
});
