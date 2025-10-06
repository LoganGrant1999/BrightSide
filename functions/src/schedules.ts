import {onSchedule} from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import {runIngest} from "./ingest/runIngest";
import {sendDigestToTopic} from "./dailyDigest";
import {recordIngestHealth, recordDigestHealth} from "./health";
import {rotateFeatured} from "./rotateFeatured";

/**
 * Scheduled ingestion for Salt Lake City metro
 * Runs at 04:40 America/Denver (Mountain Time)
 * Ensures fresh content by 5am local rolling window
 */
export const ingestSlc = onSchedule(
  {
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/Denver",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running scheduled ingestion for SLC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await runIngest("slc");
      await recordIngestHealth("slc");
      logger.info("SLC ingestion completed successfully");
    } catch (error) {
      logger.error("SLC ingestion failed:", error);
      throw error;
    }
  }
);

/**
 * Scheduled ingestion for New York City metro
 * Runs at 04:40 America/New_York (Eastern Time)
 * Ensures fresh content by 5am local rolling window
 */
export const ingestNyc = onSchedule(
  {
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running scheduled ingestion for NYC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await runIngest("nyc");
      await recordIngestHealth("nyc");
      logger.info("NYC ingestion completed successfully");
    } catch (error) {
      logger.error("NYC ingestion failed:", error);
      throw error;
    }
  }
);

/**
 * Scheduled ingestion for Greenville-Spartanburg metro
 * Runs at 04:40 America/New_York (Eastern Time)
 * Ensures fresh content by 5am local rolling window
 */
export const ingestGsp = onSchedule(
  {
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running scheduled ingestion for GSP", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await runIngest("gsp");
      await recordIngestHealth("gsp");
      logger.info("GSP ingestion completed successfully");
    } catch (error) {
      logger.error("GSP ingestion failed:", error);
      throw error;
    }
  }
);

// ============================================================================
// Daily Digest Schedulers
// ============================================================================

/**
 * Daily digest for Salt Lake City metro
 * Runs at 07:00 America/Denver (Mountain Time)
 * Sends "Good Morning" notification with top 3 articles
 */
export const digestSlc = onSchedule(
  {
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/Denver",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running daily digest for SLC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await sendDigestToTopic("slc");
      await recordDigestHealth("slc");
      logger.info("SLC digest sent successfully");
    } catch (error) {
      logger.error("SLC digest failed:", error);
      throw error;
    }
  }
);

/**
 * Daily digest for New York City metro
 * Runs at 07:00 America/New_York (Eastern Time)
 * Sends "Good Morning" notification with top 3 articles
 */
export const digestNyc = onSchedule(
  {
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running daily digest for NYC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await sendDigestToTopic("nyc");
      await recordDigestHealth("nyc");
      logger.info("NYC digest sent successfully");
    } catch (error) {
      logger.error("NYC digest failed:", error);
      throw error;
    }
  }
);

/**
 * Daily digest for Greenville-Spartanburg metro
 * Runs at 07:00 America/New_York (Eastern Time)
 * Sends "Good Morning" notification with top 3 articles
 */
export const digestGsp = onSchedule(
  {
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running daily digest for GSP", {
      scheduledTime: event.scheduleTime,
    });

    try {
      await sendDigestToTopic("gsp");
      await recordDigestHealth("gsp");
      logger.info("GSP digest sent successfully");
    } catch (error) {
      logger.error("GSP digest failed:", error);
      throw error;
    }
  }
);

// ============================================================================
// Featured Article Rotation Schedulers
// ============================================================================

/**
 * Rotate featured articles for Salt Lake City metro
 * Runs at 06:00 America/Denver (Mountain Time)
 * Features top articles from past 7 days, skips manual pins
 */
export const rotateFeaturedSlc = onSchedule(
  {
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/Denver",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running featured rotation for SLC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      const count = await rotateFeatured("slc");
      logger.info(`SLC featured rotation completed: ${count} articles featured`);
    } catch (error) {
      logger.error("SLC featured rotation failed:", error);
      throw error;
    }
  }
);

/**
 * Rotate featured articles for New York City metro
 * Runs at 06:00 America/New_York (Eastern Time)
 * Features top articles from past 7 days, skips manual pins
 */
export const rotateFeaturedNyc = onSchedule(
  {
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running featured rotation for NYC", {
      scheduledTime: event.scheduleTime,
    });

    try {
      const count = await rotateFeatured("nyc");
      logger.info(`NYC featured rotation completed: ${count} articles featured`);
    } catch (error) {
      logger.error("NYC featured rotation failed:", error);
      throw error;
    }
  }
);

/**
 * Rotate featured articles for Greenville-Spartanburg metro
 * Runs at 06:00 America/New_York (Eastern Time)
 * Features top articles from past 7 days, skips manual pins
 */
export const rotateFeaturedGsp = onSchedule(
  {
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
  },
  async (event) => {
    logger.info("Running featured rotation for GSP", {
      scheduledTime: event.scheduleTime,
    });

    try {
      const count = await rotateFeatured("gsp");
      logger.info(`GSP featured rotation completed: ${count} articles featured`);
    } catch (error) {
      logger.error("GSP featured rotation failed:", error);
      throw error;
    }
  }
);
