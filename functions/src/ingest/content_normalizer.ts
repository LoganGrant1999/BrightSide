/**
 * Content Normalizer
 * Converts RSS items to ArticleFs format for Firestore
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { RssItem } from "./rss_parser";

export interface ArticleFs {
  title: string;
  summary: string;
  source_name: string;
  source_url: string;
  image_url: string | null;
  publish_time: admin.firestore.Timestamp;
  metro_id: string;
  status: "published" | "draft";
  is_featured: boolean;
  featured_start: admin.firestore.Timestamp | null;
  featured_end: admin.firestore.Timestamp | null;
  like_count_total: number;
  like_count_24h: number;
  hot_score: number;
  created_at: admin.firestore.Timestamp;
  updated_at: admin.firestore.Timestamp;
}

/**
 * Normalize RSS item to ArticleFs format
 * @param item - RSS item
 * @param sourceName - Name of the news source
 * @param metroId - Metro identifier (slc, nyc, gsp)
 * @returns Normalized article document
 */
export function normalize(
  item: RssItem,
  sourceName: string,
  metroId: string
): ArticleFs {
  // Parse publish date
  let publishTime: admin.firestore.Timestamp;
  if (item.pubDate) {
    try {
      publishTime = admin.firestore.Timestamp.fromDate(new Date(item.pubDate));
    } catch (error) {
      logger.warn(`Invalid pubDate: ${item.pubDate}, using current time`);
      publishTime = admin.firestore.Timestamp.now();
    }
  } else {
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
export function generateArticleHash(sourceUrl: string): string {
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
export async function articleExists(
  db: admin.firestore.Firestore,
  sourceUrl: string
): Promise<boolean> {
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
export async function normalizeAndDedupe(
  db: admin.firestore.Firestore,
  items: RssItem[],
  sourceName: string,
  metroId: string
): Promise<ArticleFs[]> {
  const articles: ArticleFs[] = [];

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

  logger.info(
    `Normalized ${articles.length} unique articles from ${items.length} items`
  );
  return articles;
}
