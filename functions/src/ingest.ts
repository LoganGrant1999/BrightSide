import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import RssParser from "rss-parser";
import {createHash} from "crypto";

const parser = new RssParser({
  customFields: {
    item: [
      ["media:content", "media"],
      ["media:thumbnail", "thumbnail"],
      ["enclosure", "enclosure"],
    ],
  },
});

interface RssItem {
  title?: string;
  link?: string;
  pubDate?: string;
  contentSnippet?: string;
  content?: string;
  guid?: string;
  enclosure?: {url?: string};
  media?: {$?: {url?: string}};
  thumbnail?: {$?: {url?: string}};
}

interface Source {
  rss_url: string;
  source_name: string;
  weight: number;
  active: boolean;
}

interface NormalizedArticle {
  id: string;
  metroId: string;
  title: string;
  snippet: string;
  body: string; // Empty per ToS - we only link out
  imageUrl: string | null;
  sourceName: string;
  sourceUrl: string;
  status: string;
  likeCount: number;
  featured: boolean;
  publishedAt: admin.firestore.Timestamp;
  createdAt: admin.firestore.FieldValue;
  updatedAt: admin.firestore.FieldValue;
}

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
export async function fetchRss(url: string): Promise<RssItem[]> {
  try {
    logger.info(`Fetching RSS feed: ${url}`);
    const feed = await parser.parseURL(url);
    logger.info(`Fetched ${feed.items.length} items from ${url}`);
    return feed.items as RssItem[];
  } catch (error) {
    logger.error(`Error fetching RSS feed ${url}:`, error);
    return [];
  }
}

/**
 * Simple positivity filter using keyword allow/block lists
 * Returns true if item passes filter (is positive enough)
 */
export function positivityFilter(item: RssItem): boolean {
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
function extractImageUrl(item: RssItem): string | null {
  // Try media:content
  if (item.media && typeof item.media === "object") {
    const media = item.media as {$?: {url?: string}};
    if (media.$?.url) return media.$?.url;
  }

  // Try media:thumbnail
  if (item.thumbnail && typeof item.thumbnail === "object") {
    const thumb = item.thumbnail as {$?: {url?: string}};
    if (thumb.$?.url) return thumb.$?.url;
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
function generateArticleHash(
  sourceUrl: string,
  title: string,
  sourceName: string,
  publishDate: string
): string {
  const key = sourceUrl || `${title}|${sourceName}|${publishDate}`;
  return createHash("sha256").update(key).digest("hex").substring(0, 16);
}

/**
 * Normalize RSS item to Firestore article format
 */
export function normalize(
  item: RssItem,
  metroId: string,
  sourceName: string
): NormalizedArticle | null {
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

  const hash = generateArticleHash(
    item.link,
    item.title,
    sourceName,
    item.pubDate || new Date().toISOString()
  );

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
 * - Limits to 5 articles per day per metro
 * - Uses upsert pattern (won't overwrite existing likes)
 */
export async function writeCandidates(
  metroId: string,
  items: NormalizedArticle[]
): Promise<number> {
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

  logger.info(
    `Metro ${metroId}: ${existingCount} articles today, ${slotsAvailable} slots available`
  );

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
    } else {
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
export async function runIngest(metroId: string): Promise<void> {
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
    const data = doc.data() as Source;
    return {
      id: doc.id,
      ...data,
    };
  });

  logger.info(`Found ${sources.length} active sources for ${metroId}`);

  // Fetch and process all sources
  const allCandidates: NormalizedArticle[] = [];

  for (const source of sources) {
    try {
      const items = await fetchRss(source.rss_url);
      const filtered = items.filter(positivityFilter);

      logger.info(
        `Source ${source.source_name}: ${items.length} items, ` +
        `${filtered.length} passed filter`
      );

      const normalized = filtered
        .map((item) => normalize(item, metroId, source.source_name))
        .filter((n): n is NormalizedArticle => n !== null);

      // Weight articles by source weight (repeat entries)
      for (let i = 0; i < source.weight; i++) {
        allCandidates.push(...normalized);
      }
    } catch (error) {
      logger.error(`Error processing source ${source.source_name}:`, error);
    }
  }

  // Sort by publish date (newest first)
  allCandidates.sort((a, b) =>
    b.publishedAt.toMillis() - a.publishedAt.toMillis()
  );

  logger.info(`Metro ${metroId}: ${allCandidates.length} total candidates`);

  // Write to Firestore (respects daily limit)
  const written = await writeCandidates(metroId, allCandidates);

  logger.info(
    `Metro ${metroId}: Ingestion complete. Wrote ${written} new articles.`
  );
}
