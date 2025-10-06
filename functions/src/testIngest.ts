/**
 * Manual Test Trigger for RSS Ingestion
 * HTTP endpoint to manually trigger ingestion for testing
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { runIngest } from "./ingest/runIngest";

/**
 * HTTP function: Manual trigger for testing ingestion
 * Usage: GET /testIngest?metro=slc
 */
export const testIngest = onRequest(async (req, res) => {
  const metroId = req.query.metro as string;

  if (!["slc", "nyc", "gsp"].includes(metroId)) {
    res.status(400).send("Invalid metro. Must be slc, nyc, or gsp");
    return;
  }

  try {
    logger.info(`Manual ingestion triggered for: ${metroId}`);
    const count = await runIngest(metroId);

    res.status(200).json({
      success: true,
      metro: metroId,
      articlesIngested: count,
      message: `Successfully ingested ${count} articles for ${metroId}`,
    });
  } catch (error) {
    logger.error(`Manual ingestion failed for ${metroId}:`, error);
    res.status(500).json({
      success: false,
      metro: metroId,
      error: String(error),
    });
  }
});
