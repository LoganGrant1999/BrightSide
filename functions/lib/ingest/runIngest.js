"use strict";
/**
 * RSS Ingestion Orchestrator
 * Main entry point for daily news ingestion per metro
 */
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
exports.runIngest = runIngest;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
const rss_parser_1 = require("./rss_parser");
const positivity_filter_1 = require("./positivity_filter");
/**
 * Run daily ingestion for a specific metro
 * @param metroId - Metro identifier (slc, nyc, gsp)
 * @returns Number of articles ingested
 */
async function runIngest(metroId) {
    const db = admin.firestore();
    logger.info(`Starting ingestion for metro: ${metroId}`);
    try {
        // 1. Fetch RSS sources from Firestore
        const sourcesDoc = await db
            .collection("system")
            .doc("sources")
            .collection(metroId)
            .doc("sources")
            .get();
        if (!sourcesDoc.exists) {
            logger.warn(`No sources configured for metro: ${metroId}`);
            return 0;
        }
        const sourcesData = sourcesDoc.data();
        if (!sourcesData) {
            logger.warn(`Empty sources doc for metro: ${metroId}`);
            return 0;
        }
        // Parse sources array
        const sources = [];
        for (const value of Object.values(sourcesData)) {
            if (typeof value === "object" && value !== null) {
                const source = value;
                if (source.active) {
                    sources.push(source);
                }
            }
        }
        if (sources.length === 0) {
            logger.warn(`No active sources for metro: ${metroId}`);
            return 0;
        }
        logger.info(`Found ${sources.length} active sources for ${metroId}`);
        // 2. Fetch RSS items from all sources with logging
        const allItems = [];
        const sourceMetrics = {};
        for (const source of sources) {
            logger.info(`📰 Fetching from ${source.source_name}: ${source.rss_url}`);
            try {
                const items = await (0, rss_parser_1.fetchRssItems)(source.rss_url);
                logger.info(`   ✓ Fetched ${items.length} items from ${source.source_name}`);
                // Initialize metrics for this source
                sourceMetrics[source.source_name] = {
                    fetched: items.length,
                    positive: 0,
                    final: 0,
                };
                // Tag items with source info
                const taggedItems = items.map((item) => ({
                    ...item,
                    _sourceName: source.source_name,
                    _weight: source.weight,
                }));
                allItems.push(...taggedItems);
            }
            catch (error) {
                logger.error(`   ✗ Failed to fetch from ${source.source_name}:`, error);
                sourceMetrics[source.source_name] = {
                    fetched: 0,
                    positive: 0,
                    final: 0,
                };
            }
        }
        logger.info(`📊 Total items fetched: ${allItems.length}`);
        // 3. Filter for positive content
        const positiveItems = (0, positivity_filter_1.keepPositive)(allItems);
        // Track positive items per source
        for (const item of positiveItems) {
            const sourceName = item._sourceName;
            if (sourceName && sourceMetrics[sourceName]) {
                sourceMetrics[sourceName].positive++;
            }
        }
        logger.info(`✨ Positive items after filtering: ${positiveItems.length}`);
        if (positiveItems.length === 0) {
            logger.warn(`No positive items found for metro: ${metroId}`);
            return 0;
        }
        // 4. Get top 10 by positivity score
        const topItems = (0, positivity_filter_1.getTopPositive)(positiveItems, 10);
        logger.info(`🎯 Top items selected: ${topItems.length}`);
        // 5. Normalize and dedupe
        const articles = [];
        for (const item of topItems) {
            const sourceName = item._sourceName || "Unknown Source";
            // Check if already exists
            const existingSnapshot = await db
                .collection("articles")
                .where("source_url", "==", item.link)
                .limit(1)
                .get();
            if (!existingSnapshot.empty) {
                logger.debug(`Skipping duplicate: ${item.title}`);
                continue;
            }
            // Parse publish date
            let publishTime;
            if (item.pubDate) {
                try {
                    publishTime = admin.firestore.Timestamp.fromDate(new Date(item.pubDate));
                }
                catch (error) {
                    logger.warn(`Invalid pubDate: ${item.pubDate}, using current time`);
                    publishTime = admin.firestore.Timestamp.now();
                }
            }
            else {
                publishTime = admin.firestore.Timestamp.now();
            }
            // Clean and truncate summary
            let summary = item.summary || item.title;
            summary = summary
                .replace(/<[^>]*>/g, "") // Strip HTML tags
                .replace(/&[^;]+;/g, " ") // Strip HTML entities
                .trim();
            if (summary.length > 300) {
                summary = summary.substring(0, 297) + "...";
            }
            const now = admin.firestore.Timestamp.now();
            const article = {
                title: item.title.substring(0, 200),
                summary,
                source_name: sourceName,
                source_url: item.link,
                image_url: item.imageUrl || null,
                publish_time: publishTime,
                metro_id: metroId,
                status: "published",
                is_featured: false,
                featured_start: null,
                featured_end: null,
                like_count_total: 0,
                like_count_24h: 0,
                hot_score: 0,
                created_at: now,
                updated_at: now,
            };
            articles.push(article);
            // Track in source metrics
            if (sourceMetrics[sourceName]) {
                sourceMetrics[sourceName].final++;
            }
        }
        // 6. Check daily limit (max 8 articles per day)
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayTimestamp = admin.firestore.Timestamp.fromDate(today);
        const todayCount = await db
            .collection("articles")
            .where("metro_id", "==", metroId)
            .where("created_at", ">=", todayTimestamp)
            .count()
            .get();
        const existingToday = todayCount.data().count;
        const remainingSlots = Math.max(0, 8 - existingToday);
        if (remainingSlots === 0) {
            logger.info(`Daily limit reached for ${metroId} (8 articles)`);
            return existingToday;
        }
        // Cap to remaining slots
        let articlesToInsert = articles.slice(0, remainingSlots);
        // 6.5. Backfill guardrail: If <3 articles after filtering, backfill from recent positive items
        const totalAfterBackfill = existingToday + articlesToInsert.length;
        if (totalAfterBackfill < 3) {
            logger.warn(`Only ${totalAfterBackfill} articles for ${metroId}, attempting backfill...`);
            // Look for positive articles from past 48h that weren't shown today
            const twoDaysAgo = new Date();
            twoDaysAgo.setHours(twoDaysAgo.getHours() - 48);
            const twoDaysAgoTimestamp = admin.firestore.Timestamp.fromDate(twoDaysAgo);
            const backfillQuery = await db
                .collection("articles")
                .where("metro_id", "==", metroId)
                .where("publish_time", ">=", twoDaysAgoTimestamp)
                .where("publish_time", "<", todayTimestamp)
                .orderBy("publish_time", "desc")
                .limit(5)
                .get();
            const backfillArticles = [];
            for (const doc of backfillQuery.docs) {
                const data = doc.data();
                // Check if already exists with this source_url
                const existsSnapshot = await db
                    .collection("articles")
                    .where("source_url", "==", data.source_url)
                    .where("created_at", ">=", todayTimestamp)
                    .limit(1)
                    .get();
                if (existsSnapshot.empty) {
                    // Re-publish as new article
                    const now = admin.firestore.Timestamp.now();
                    const backfillArticle = {
                        title: data.title,
                        summary: data.summary,
                        source_name: data.source_name,
                        source_url: data.source_url,
                        image_url: data.image_url || null,
                        publish_time: data.publish_time,
                        metro_id: metroId,
                        status: "published",
                        is_featured: false,
                        featured_start: null,
                        featured_end: null,
                        like_count_total: 0,
                        like_count_24h: 0,
                        hot_score: 0,
                        created_at: now,
                        updated_at: now,
                    };
                    backfillArticles.push(backfillArticle);
                }
            }
            if (backfillArticles.length > 0) {
                const needToBackfill = Math.min(3 - totalAfterBackfill, backfillArticles.length, remainingSlots - articlesToInsert.length);
                articlesToInsert = [
                    ...articlesToInsert,
                    ...backfillArticles.slice(0, needToBackfill),
                ];
                logger.info(`Backfilled ${needToBackfill} articles from past 48h for ${metroId}`);
            }
            else {
                logger.warn(`No suitable backfill articles found for ${metroId}`);
            }
        }
        // 7. Batch insert articles
        const batch = db.batch();
        for (const article of articlesToInsert) {
            const docRef = db.collection("articles").doc();
            batch.set(docRef, article);
        }
        await batch.commit();
        logger.info(`Ingested ${articlesToInsert.length} articles for metro: ${metroId}`);
        // 8. Update health ping with source metrics
        const finalCount = existingToday + articlesToInsert.length;
        // Log source metrics summary table
        logger.info("\n📊 Source Metrics Summary:");
        logger.info("─".repeat(80));
        logger.info("Source                | Fetched | Positive | Final | Success Rate");
        logger.info("─".repeat(80));
        for (const [sourceName, metrics] of Object.entries(sourceMetrics)) {
            const successRate = metrics.fetched > 0
                ? ((metrics.final / metrics.fetched) * 100).toFixed(1)
                : "0.0";
            logger.info(`${sourceName.padEnd(20)} | ${String(metrics.fetched).padStart(7)} | ` +
                `${String(metrics.positive).padStart(8)} | ${String(metrics.final).padStart(5)} | ${successRate}%`);
        }
        logger.info("─".repeat(80));
        await db
            .collection("system")
            .doc("health")
            .set({
            [metroId]: {
                lastIngestAt: admin.firestore.FieldValue.serverTimestamp(),
                lastIngestCount: articlesToInsert.length,
                countToday: finalCount,
                status: "ok",
                sourceMetrics: sourceMetrics,
            },
        }, { merge: true });
        return articlesToInsert.length;
    }
    catch (error) {
        logger.error(`Ingestion failed for ${metroId}:`, error);
        // Update health with error status
        await db
            .collection("system")
            .doc("health")
            .set({
            [metroId]: {
                lastIngestAt: admin.firestore.FieldValue.serverTimestamp(),
                lastIngestCount: 0,
                countToday: 0,
                status: "error",
                error: String(error),
            },
        }, { merge: true });
        throw error;
    }
}
//# sourceMappingURL=runIngest.js.map