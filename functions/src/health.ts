/**
 * Health monitoring for scheduled functions
 * Writes heartbeat timestamps to /system/health/{metroId}
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

const db = admin.firestore();

/**
 * Record successful ingest run for a metro
 */
export async function recordIngestHealth(metroId: string): Promise<void> {
  try {
    await db.collection("system").doc("health").set(
      {
        [metroId]: {
          lastIngestAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "ok",
        },
      },
      { merge: true }
    );
    logger.info(`Health ping recorded for ${metroId} ingest`);
  } catch (error) {
    logger.error(`Failed to record health ping for ${metroId}:`, error);
  }
}

/**
 * Record successful digest run for a metro
 */
export async function recordDigestHealth(metroId: string): Promise<void> {
  try {
    await db.collection("system").doc("health").set(
      {
        [metroId]: {
          lastDigestAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "ok",
        },
      },
      { merge: true }
    );
    logger.info(`Health ping recorded for ${metroId} digest`);
  } catch (error) {
    logger.error(`Failed to record health ping for ${metroId}:`, error);
  }
}

/**
 * Record featured rotation health
 */
export async function recordFeaturedRotationHealth(): Promise<void> {
  try {
    await db.collection("system").doc("health").set(
      {
        featured: {
          lastRotationAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "ok",
        },
      },
      { merge: true }
    );
    logger.info("Health ping recorded for featured rotation");
  } catch (error) {
    logger.error("Failed to record health ping for featured rotation:", error);
  }
}
