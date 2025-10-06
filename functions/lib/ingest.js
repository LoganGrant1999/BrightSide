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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchRss = fetchRss;
exports.positivityFilter = positivityFilter;
exports.normalize = normalize;
exports.writeCandidates = writeCandidates;
exports.runIngest = runIngest;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
const rss_parser_1 = __importDefault(require("rss-parser"));
const crypto_1 = require("crypto");
const parser = new rss_parser_1.default({
    customFields: {
        item: [
            ["media:content", "media"],
            ["media:thumbnail", "thumbnail"],
            ["enclosure", "enclosure"],
        ],
    },
});
// Keyword filtering for positivity
const BLOCK_KEYWORDS = [
    "murder", "killed", "death", "shooting", "shot", "stabbed", "assault",
    "attack", "terror", "bomb", "explosion", "crash", "accident", "fatal",
    "dies", "dead", "violence", "crime", "arrested", "prison", "jail",
    "war", "conflict", "politics", "election", "trump", "biden", "senate",
    "congress", "republican", "democrat", "protest", "riot",
];
const ALLOW_KEYWORDS = [
    "celebrate", "success", "hero", "rescue", "saved", "help", "donate",
    "charity", "community", "local", "achievement", "award", "graduate",
    "innovation", "breakthrough", "opens", "launch", "new", "first",
    "anniversary", "festival", "event", "art", "music", "culture",
    "volunteer", "giving", "inspire", "uplift", "positive", "good news",
];
/**
 * Fetch and parse RSS feed from URL
 */
async function fetchRss(url) {
    try {
        logger.info(`Fetching RSS feed: ${url}`);
        const feed = await parser.parseURL(url);
        logger.info(`Fetched ${feed.items.length} items from ${url}`);
        return feed.items;
    }
    catch (error) {
        logger.error(`Error fetching RSS feed ${url}:`, error);
        return [];
    }
}
/**
 * Simple positivity filter using keyword allow/block lists
 * Returns true if item passes filter (is positive enough)
 */
function positivityFilter(item) {
    const text = `${item.title || ""} ${item.contentSnippet || ""}`.toLowerCase();
    // Block if contains any negative keywords
    const hasBlockedKeyword = BLOCK_KEYWORDS.some((kw) => text.includes(kw));
    if (hasBlockedKeyword) {
        return false;
    }
    // Prefer items with positive keywords, but don't require them
    // This allows neutral local news through
    const hasAllowKeyword = ALLOW_KEYWORDS.some((kw) => text.includes(kw));
    return hasAllowKeyword || text.includes("local");
}
/**
 * Extract image URL from RSS item (try multiple fields)
 */
function extractImageUrl(item) {
    // Try media:content
    if (item.media && typeof item.media === "object") {
        const media = item.media;
        if (media.$?.url)
            return media.$?.url;
    }
    // Try media:thumbnail
    if (item.thumbnail && typeof item.thumbnail === "object") {
        const thumb = item.thumbnail;
        if (thumb.$?.url)
            return thumb.$?.url;
    }
    // Try enclosure
    if (item.enclosure?.url) {
        return item.enclosure.url;
    }
    return null;
}
/**
 * Generate stable hash for deduplication
 * Uses source_url or combination of title+source+date
 */
function generateArticleHash(sourceUrl, title, sourceName, publishDate) {
    const key = sourceUrl || `${title}|${sourceName}|${publishDate}`;
    return (0, crypto_1.createHash)("sha256").update(key).digest("hex").substring(0, 16);
}
/**
 * Normalize RSS item to Firestore article format
 */
function normalize(item, metroId, sourceName) {
    if (!item.title || !item.link) {
        logger.warn("Skipping item without title or link");
        return null;
    }
    const publishedAt = item.pubDate ?
        admin.firestore.Timestamp.fromDate(new Date(item.pubDate)) :
        admin.firestore.Timestamp.now();
    const snippet = (item.contentSnippet || item.content || "")
        .substring(0, 300)
        .trim();
    const hash = generateArticleHash(item.link, item.title, sourceName, item.pubDate || new Date().toISOString());
    return {
        id: hash,
        metroId,
        title: item.title.trim(),
        snippet: snippet || "Read more at source",
        body: "", // Never store full body - ToS compliance
        imageUrl: extractImageUrl(item),
        sourceName,
        sourceUrl: item.link,
        status: "published",
        likeCount: 0,
        featured: false,
        publishedAt,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
}
/**
 * Write candidate articles to Firestore
 * - Dedupes by document ID (hash)
 * - Limits to 8 articles per day per metro
 * - Uses upsert pattern (won't overwrite existing likes)
 */
async function writeCandidates(metroId, items) {
    const db = admin.firestore();
    const batch = db.batch();
    // Check how many articles already published today for this metro
    const startOfDay = new Date();
    startOfDay.setHours(5, 0, 0, 0); // 5am local cutoff
    const existingToday = await db
        .collection("articles")
        .where("metroId", "==", metroId)
        .where("publishedAt", ">=", admin.firestore.Timestamp.fromDate(startOfDay))
        .get();
    const existingCount = existingToday.size;
    const maxDaily = 8;
    const slotsAvailable = Math.max(0, maxDaily - existingCount);
    logger.info(`Metro ${metroId}: ${existingCount} articles today, ${slotsAvailable} slots available`);
    if (slotsAvailable === 0) {
        logger.info(`Metro ${metroId}: Already at daily limit (${maxDaily})`);
        return 0;
    }
    // Take only what we have slots for
    const itemsToWrite = items.slice(0, slotsAvailable);
    let writtenCount = 0;
    for (const item of itemsToWrite) {
        const docRef = db.collection("articles").doc(item.id);
        // Check if already exists to preserve likeCount
        const existing = await docRef.get();
        if (existing.exists) {
            // Update only metadata, preserve likes
            batch.update(docRef, {
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            logger.info(`Updated existing article: ${item.id}`);
        }
        else {
            // New article
            batch.set(docRef, item);
            writtenCount++;
            logger.info(`Created new article: ${item.id} - ${item.title}`);
        }
    }
    await batch.commit();
    logger.info(`Metro ${metroId}: Wrote ${writtenCount} new articles`);
    return writtenCount;
}
/**
 * Main ingestion function for a single metro
 * Fetches from all active sources, filters, normalizes, and writes
 */
async function runIngest(metroId) {
    logger.info(`Starting ingestion for metro: ${metroId}`);
    const db = admin.firestore();
    // Fetch sources for this metro
    const sourcesSnap = await db
        .collection("system")
        .doc("sources")
        .collection(metroId)
        .where("active", "==", true)
        .get();
    if (sourcesSnap.empty) {
        logger.warn(`No active sources configured for metro: ${metroId}`);
        return;
    }
    const sources = sourcesSnap.docs.map((doc) => {
        const data = doc.data();
        return {
            id: doc.id,
            ...data,
        };
    });
    logger.info(`Found ${sources.length} active sources for ${metroId}`);
    // Fetch and process all sources
    const allCandidates = [];
    for (const source of sources) {
        try {
            const items = await fetchRss(source.rss_url);
            const filtered = items.filter(positivityFilter);
            logger.info(`Source ${source.source_name}: ${items.length} items, ` +
                `${filtered.length} passed filter`);
            const normalized = filtered
                .map((item) => normalize(item, metroId, source.source_name))
                .filter((n) => n !== null);
            // Weight articles by source weight (repeat entries)
            for (let i = 0; i < source.weight; i++) {
                allCandidates.push(...normalized);
            }
        }
        catch (error) {
            logger.error(`Error processing source ${source.source_name}:`, error);
        }
    }
    // Sort by publish date (newest first)
    allCandidates.sort((a, b) => b.publishedAt.toMillis() - a.publishedAt.toMillis());
    logger.info(`Metro ${metroId}: ${allCandidates.length} total candidates`);
    // Write to Firestore (respects daily limit)
    const written = await writeCandidates(metroId, allCandidates);
    logger.info(`Metro ${metroId}: Ingestion complete. Wrote ${written} new articles.`);
}
//# sourceMappingURL=ingest.js.map