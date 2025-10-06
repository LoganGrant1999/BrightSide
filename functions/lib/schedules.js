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
exports.rotateFeaturedGsp = exports.rotateFeaturedNyc = exports.rotateFeaturedSlc = exports.digestGsp = exports.digestNyc = exports.digestSlc = exports.ingestGsp = exports.ingestNyc = exports.ingestSlc = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const logger = __importStar(require("firebase-functions/logger"));
const runIngest_1 = require("./ingest/runIngest");
const dailyDigest_1 = require("./dailyDigest");
const health_1 = require("./health");
const rotateFeatured_1 = require("./rotateFeatured");
/**
 * Scheduled ingestion for Salt Lake City metro
 * Runs at 04:40 America/Denver (Mountain Time)
 * Ensures fresh content by 5am local rolling window
 */
exports.ingestSlc = (0, scheduler_1.onSchedule)({
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/Denver",
    region: "us-central1",
}, async (event) => {
    logger.info("Running scheduled ingestion for SLC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, runIngest_1.runIngest)("slc");
        await (0, health_1.recordIngestHealth)("slc");
        logger.info("SLC ingestion completed successfully");
    }
    catch (error) {
        logger.error("SLC ingestion failed:", error);
        throw error;
    }
});
/**
 * Scheduled ingestion for New York City metro
 * Runs at 04:40 America/New_York (Eastern Time)
 * Ensures fresh content by 5am local rolling window
 */
exports.ingestNyc = (0, scheduler_1.onSchedule)({
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running scheduled ingestion for NYC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, runIngest_1.runIngest)("nyc");
        await (0, health_1.recordIngestHealth)("nyc");
        logger.info("NYC ingestion completed successfully");
    }
    catch (error) {
        logger.error("NYC ingestion failed:", error);
        throw error;
    }
});
/**
 * Scheduled ingestion for Greenville-Spartanburg metro
 * Runs at 04:40 America/New_York (Eastern Time)
 * Ensures fresh content by 5am local rolling window
 */
exports.ingestGsp = (0, scheduler_1.onSchedule)({
    schedule: "40 4 * * *", // 04:40 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running scheduled ingestion for GSP", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, runIngest_1.runIngest)("gsp");
        await (0, health_1.recordIngestHealth)("gsp");
        logger.info("GSP ingestion completed successfully");
    }
    catch (error) {
        logger.error("GSP ingestion failed:", error);
        throw error;
    }
});
// ============================================================================
// Daily Digest Schedulers
// ============================================================================
/**
 * Daily digest for Salt Lake City metro
 * Runs at 07:00 America/Denver (Mountain Time)
 * Sends "Good Morning" notification with top 3 articles
 */
exports.digestSlc = (0, scheduler_1.onSchedule)({
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/Denver",
    region: "us-central1",
}, async (event) => {
    logger.info("Running daily digest for SLC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, dailyDigest_1.sendDigestToTopic)("slc");
        await (0, health_1.recordDigestHealth)("slc");
        logger.info("SLC digest sent successfully");
    }
    catch (error) {
        logger.error("SLC digest failed:", error);
        throw error;
    }
});
/**
 * Daily digest for New York City metro
 * Runs at 07:00 America/New_York (Eastern Time)
 * Sends "Good Morning" notification with top 3 articles
 */
exports.digestNyc = (0, scheduler_1.onSchedule)({
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running daily digest for NYC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, dailyDigest_1.sendDigestToTopic)("nyc");
        await (0, health_1.recordDigestHealth)("nyc");
        logger.info("NYC digest sent successfully");
    }
    catch (error) {
        logger.error("NYC digest failed:", error);
        throw error;
    }
});
/**
 * Daily digest for Greenville-Spartanburg metro
 * Runs at 07:00 America/New_York (Eastern Time)
 * Sends "Good Morning" notification with top 3 articles
 */
exports.digestGsp = (0, scheduler_1.onSchedule)({
    schedule: "0 7 * * *", // 07:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running daily digest for GSP", {
        scheduledTime: event.scheduleTime,
    });
    try {
        await (0, dailyDigest_1.sendDigestToTopic)("gsp");
        await (0, health_1.recordDigestHealth)("gsp");
        logger.info("GSP digest sent successfully");
    }
    catch (error) {
        logger.error("GSP digest failed:", error);
        throw error;
    }
});
// ============================================================================
// Featured Article Rotation Schedulers
// ============================================================================
/**
 * Rotate featured articles for Salt Lake City metro
 * Runs at 06:00 America/Denver (Mountain Time)
 * Features top articles from past 7 days, skips manual pins
 */
exports.rotateFeaturedSlc = (0, scheduler_1.onSchedule)({
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/Denver",
    region: "us-central1",
}, async (event) => {
    logger.info("Running featured rotation for SLC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        const count = await (0, rotateFeatured_1.rotateFeatured)("slc");
        logger.info(`SLC featured rotation completed: ${count} articles featured`);
    }
    catch (error) {
        logger.error("SLC featured rotation failed:", error);
        throw error;
    }
});
/**
 * Rotate featured articles for New York City metro
 * Runs at 06:00 America/New_York (Eastern Time)
 * Features top articles from past 7 days, skips manual pins
 */
exports.rotateFeaturedNyc = (0, scheduler_1.onSchedule)({
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running featured rotation for NYC", {
        scheduledTime: event.scheduleTime,
    });
    try {
        const count = await (0, rotateFeatured_1.rotateFeatured)("nyc");
        logger.info(`NYC featured rotation completed: ${count} articles featured`);
    }
    catch (error) {
        logger.error("NYC featured rotation failed:", error);
        throw error;
    }
});
/**
 * Rotate featured articles for Greenville-Spartanburg metro
 * Runs at 06:00 America/New_York (Eastern Time)
 * Features top articles from past 7 days, skips manual pins
 */
exports.rotateFeaturedGsp = (0, scheduler_1.onSchedule)({
    schedule: "0 6 * * *", // 06:00 daily
    timeZone: "America/New_York",
    region: "us-central1",
}, async (event) => {
    logger.info("Running featured rotation for GSP", {
        scheduledTime: event.scheduleTime,
    });
    try {
        const count = await (0, rotateFeatured_1.rotateFeatured)("gsp");
        logger.info(`GSP featured rotation completed: ${count} articles featured`);
    }
    catch (error) {
        logger.error("GSP featured rotation failed:", error);
        throw error;
    }
});
//# sourceMappingURL=schedules.js.map