/**
 * RSS Feed Parser
 * Fetches and parses RSS feeds to extract article items
 */

import Parser from "rss-parser";
import * as logger from "firebase-functions/logger";

export interface RssItem {
  title: string;
  link: string;
  pubDate?: string;
  summary?: string;
  imageUrl?: string;
}

const parser = new Parser({
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
export async function fetchRssItems(url: string): Promise<RssItem[]> {
  try {
    logger.info(`Fetching RSS feed: ${url}`);

    const feed = await parser.parseURL(url);
    const items: RssItem[] = [];

    for (const item of feed.items) {
      // Skip items without title or link
      if (!item.title || !item.link) {
        continue;
      }

      // Extract image URL from various possible fields
      let imageUrl: string | undefined;

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
        const imgMatch = item["content:encoded"].match(
          /<img[^>]+src="([^">]+)"/
        );
        if (imgMatch) {
          imageUrl = imgMatch[1];
        }
      }

      items.push({
        title: item.title.trim(),
        link: item.link.trim(),
        pubDate: item.pubDate || item.isoDate,
        summary:
          item.contentSnippet?.trim() ||
          item.content?.trim() ||
          item.description?.trim(),
        imageUrl,
      });
    }

    logger.info(`Parsed ${items.length} items from ${url}`);
    return items;
  } catch (error) {
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
export async function fetchMultipleFeeds(
  urls: string[]
): Promise<RssItem[]> {
  const results = await Promise.allSettled(
    urls.map((url) => fetchRssItems(url))
  );

  const allItems: RssItem[] = [];

  for (const result of results) {
    if (result.status === "fulfilled") {
      allItems.push(...result.value);
    } else {
      logger.error("Feed fetch failed:", result.reason);
    }
  }

  return allItems;
}
