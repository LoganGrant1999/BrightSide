"use strict";
/**
 * Content Normalizer
 * Converts RSS items to ArticleFs format for Firestore
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
exports.normalize = normalize;
exports.generateArticleHash = generateArticleHash;
exports.articleExists = articleExists;
exports.normalizeAndDedupe = normalizeAndDedupe;
const admin = __importStar(require("firebase-admin"));
const logger = __importStar(require("firebase-functions/logger"));
/**
 * Normalize RSS item to ArticleFs format
 * @param item - RSS item
 * @param sourceName - Name of the news source
 * @param metroId - Metro identifier (slc, nyc, gsp)
 * @returns Normalized article document
 */
function normalize(item, sourceName, metroId) {
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
    // Truncate to 300 chars for snippet
    if (summary.length > 300) {
        summary = summary.substring(0, 297) + "...";
    }
    const now = admin.firestore.Timestamp.now();
    return {
        title: item.title.substring(0, 200), // Truncate title to 200 chars
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
}
/**
 * Generate a stable hash for deduplication
 * Based on source URL to prevent duplicate articles
 */
function generateArticleHash(sourceUrl) {
    // Simple hash using URL
    // In production, consider using a crypto hash
    const url = new URL(sourceUrl);
    return Buffer.from(url.pathname + url.search)
        .toString("base64")
        .substring(0, 32);
}
/**
 * Check if article already exists in Firestore
 * @param db - Firestore instance
 * @param sourceUrl - Article source URL
 * @returns true if article exists
 */
async function articleExists(db, sourceUrl) {
    const snapshot = await db
        .collection("articles")
        .where("source_url", "==", sourceUrl)
        .limit(1)
        .get();
    return !snapshot.empty;
}
/**
 * Batch normalize and filter unique items
 */
async function normalizeAndDedupe(db, items, sourceName, metroId) {
    const articles = [];
    for (const item of items) {
        // Check if already exists
        const exists = await articleExists(db, item.link);
        if (exists) {
            logger.debug(`Skipping duplicate: ${item.title}`);
            continue;
        }
        // Normalize to ArticleFs
        const article = normalize(item, sourceName, metroId);
        articles.push(article);
    }
    logger.info(`Normalized ${articles.length} unique articles from ${items.length} items`);
    return articles;
}
//# sourceMappingURL=content_normalizer.js.map