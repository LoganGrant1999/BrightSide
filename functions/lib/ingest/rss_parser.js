"use strict";
/**
 * RSS Feed Parser
 * Fetches and parses RSS feeds to extract article items
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchRssItems = fetchRssItems;
exports.fetchMultipleFeeds = fetchMultipleFeeds;
const rss_parser_1 = __importDefault(require("rss-parser"));
const logger = __importStar(require("firebase-functions/logger"));
const parser = new rss_parser_1.default({
    timeout: 10000, // 10 second timeout
    headers: {
        "User-Agent": "BrightSide-Bot/1.0",
    },
});
/**
 * Fetch and parse RSS feed from URL
 * @param url - RSS feed URL
 * @returns Array of parsed RSS items
 */
async function fetchRssItems(url) {
    try {
        logger.info(`Fetching RSS feed: ${url}`);
        const feed = await parser.parseURL(url);
        const items = [];
        for (const item of feed.items) {
            // Skip items without title or link
            if (!item.title || !item.link) {
                continue;
            }
            // Extract image URL from various possible fields
            let imageUrl;
            // Try enclosure (common in RSS)
            if (item.enclosure?.url) {
                imageUrl = item.enclosure.url;
            }
            // Try media:content (common in Atom feeds)
            else if (item["media:content"]?.["$"]?.url) {
                imageUrl = item["media:content"]["$"].url;
            }
            // Try media:thumbnail
            else if (item["media:thumbnail"]?.["$"]?.url) {
                imageUrl = item["media:thumbnail"]["$"].url;
            }
            // Try content:encoded for embedded images
            else if (item["content:encoded"]) {
                const imgMatch = item["content:encoded"].match(/<img[^>]+src="([^">]+)"/);
                if (imgMatch) {
                    imageUrl = imgMatch[1];
                }
            }
            items.push({
                title: item.title.trim(),
                link: item.link.trim(),
                pubDate: item.pubDate || item.isoDate,
                summary: item.contentSnippet?.trim() ||
                    item.content?.trim() ||
                    item.description?.trim(),
                imageUrl,
            });
        }
        logger.info(`Parsed ${items.length} items from ${url}`);
        return items;
    }
    catch (error) {
        logger.error(`Error fetching RSS feed ${url}:`, error);
        // Return empty array instead of throwing to continue with other feeds
        return [];
    }
}
/**
 * Fetch items from multiple RSS feeds
 * @param urls - Array of RSS feed URLs
 * @returns Combined array of items from all feeds
 */
async function fetchMultipleFeeds(urls) {
    const results = await Promise.allSettled(urls.map((url) => fetchRssItems(url)));
    const allItems = [];
    for (const result of results) {
        if (result.status === "fulfilled") {
            allItems.push(...result.value);
        }
        else {
            logger.error("Feed fetch failed:", result.reason);
        }
    }
    return allItems;
}
//# sourceMappingURL=rss_parser.js.map