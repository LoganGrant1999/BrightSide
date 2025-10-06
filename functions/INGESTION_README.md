# BrightSide Content Ingestion Pipeline

Lightweight, ToS-compliant RSS ingestion system that fetches positive local news for each metro.

## Overview

The ingestion pipeline:
- Runs daily at **04:40 local time** for each metro (SLC, NYC, GSP)
- Fetches from RSS feeds configured in Firestore
- Filters content for positivity using keyword allow/block lists
- Stores **headline, summary, source, and link only** (no full article body)
- Limits to **8 articles per day per metro**
- Deduplicates by stable hash of source URL or title+source+date
- Articles open externally via `sourceUrl` in SFSafariViewController

## Data Model

### Source Configuration

Sources are stored in Firestore at `/system/sources/{metroId}/{sourceId}`:

```typescript
{
  rss_url: string;       // RSS/Atom feed URL
  source_name: string;   // Display name (e.g., "Salt Lake Tribune")
  weight: number;        // Priority 1-3 (higher = more articles selected)
  active: boolean;       // Enable/disable source
}
```

### Article Schema

Articles are written to `/articles/{articleId}`:

```typescript
{
  id: string;            // Stable hash for deduplication
  metroId: string;       // "slc" | "nyc" | "gsp"
  title: string;         // Article headline
  snippet: string;       // First 300 chars of description
  body: string;          // ALWAYS EMPTY (ToS compliance)
  imageUrl: string | null;
  sourceName: string;
  sourceUrl: string;     // External link to full article
  status: "published";
  likeCount: number;
  featured: boolean;
  publishedAt: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

## Adding Sources

### 1. Via Firestore Console

Navigate to Firestore and create documents:

```
/system/sources/slc/{sourceId}
  rss_url: "https://example.com/rss"
  source_name: "Example News"
  weight: 2
  active: true
```

### 2. Via Seed Script

Create or update `tool/seed_sources.ts`:

```typescript
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

const sources = {
  slc: [
    {
      id: 'salt-lake-tribune',
      rss_url: 'https://www.sltrib.com/feed/',
      source_name: 'Salt Lake Tribune',
      weight: 3,
      active: true,
    },
    {
      id: 'ksl-news',
      rss_url: 'https://www.ksl.com/rss/local-news.xml',
      source_name: 'KSL News',
      weight: 2,
      active: true,
    },
  ],
  nyc: [
    {
      id: 'gothamist',
      rss_url: 'https://gothamist.com/feed',
      source_name: 'Gothamist',
      weight: 3,
      active: true,
    },
  ],
  gsp: [
    {
      id: 'greenville-news',
      rss_url: 'https://www.greenvilleonline.com/feed/',
      source_name: 'Greenville News',
      weight: 2,
      active: true,
    },
  ],
};

async function seedSources() {
  for (const [metroId, metroSources] of Object.entries(sources)) {
    for (const source of metroSources) {
      const { id, ...data } = source;
      await db
        .collection('system')
        .doc('sources')
        .collection(metroId)
        .doc(id)
        .set(data);
      console.log(`Added source: ${metroId}/${id}`);
    }
  }
}

seedSources().then(() => process.exit(0));
```

Run with emulator:
```bash
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_sources.ts
```

## Testing Locally

### 1. Start Firebase Emulators

```bash
cd functions
npm run serve
```

This starts:
- Firestore: `localhost:8080`
- Functions: `localhost:5001`

### 2. Seed Test Sources

Add at least one source per metro (see "Adding Sources" above).

### 3. Trigger Ingestion Manually

You can call the ingestion function directly via Firebase CLI or by creating a test script:

Create `functions/test_ingest.ts`:

```typescript
import * as admin from 'firebase-admin';
import { runIngest } from './src/ingest';

// Point to emulator
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

admin.initializeApp({ projectId: 'brightside-test' });

async function test() {
  console.log('Testing ingestion for SLC...');
  await runIngest('slc');
  console.log('Done!');
}

test().catch(console.error);
```

Run:
```bash
npx ts-node test_ingest.ts
```

### 4. Verify Results

Check Firestore emulator UI at `http://localhost:4000` → Firestore tab:
- Navigate to `/articles`
- Should see 3-8 new articles for `metroId: "slc"`
- Verify `body` is empty
- Verify `sourceUrl` is populated

### 5. Test Scheduled Functions (Optional)

To test scheduled functions with emulator:

```bash
# Install Firebase emulator shell
npm install -g firebase-tools

# Start emulator with functions
firebase emulators:start --only functions,firestore

# In another terminal, trigger scheduled function
curl -X POST http://localhost:5001/brightside-dev/us-central1/ingestSlc
```

## Positivity Filtering

### Block Keywords
Articles containing these terms are **rejected**:
- Violence: murder, shooting, assault, stabbing, etc.
- Crime: arrested, prison, jail, etc.
- Politics: trump, biden, election, senate, congress, etc.
- Accidents: crash, fatal, explosion, etc.

### Allow Keywords (Preferred)
Articles with these terms are **preferred** but not required:
- Positive: celebrate, success, hero, rescue, help, donate, charity
- Community: local, community, volunteer, giving
- Achievement: award, graduate, innovation, breakthrough
- Events: festival, anniversary, art, music, culture

Neutral local news (without positive keywords) can still pass if it avoids blocked keywords.

## Deduplication

Articles are deduplicated using a stable hash:
- Primary: SHA256 of `sourceUrl`
- Fallback: SHA256 of `title|sourceName|publishDate`

Hash is truncated to 16 chars and used as document ID.

Re-running ingestion on the same day will:
- Skip existing articles (preserves `likeCount`)
- Only update `updatedAt` timestamp
- Not count toward daily limit

## Daily Limits

- **Max 8 articles/day/metro** to prevent spam
- Limit resets at 5am local time
- If limit reached, ingestion logs warning and skips
- Manual articles (admin-created) also count toward limit

## Production Schedule

Scheduled functions run daily:

| Metro | Timezone          | Schedule | UTC Equivalent |
|-------|-------------------|----------|----------------|
| SLC   | America/Denver    | 04:40    | ~11:40 UTC     |
| NYC   | America/New_York  | 04:40    | ~09:40 UTC     |
| GSP   | America/New_York  | 04:40    | ~09:40 UTC     |

This ensures fresh content is ready **before** the 5am local rolling window opens for the "Today" feed.

## Monitoring

Check Cloud Functions logs:
```bash
firebase functions:log --only ingestSlc,ingestNyc,ingestGsp
```

Key metrics to monitor:
- Articles written per metro per day
- RSS fetch failures
- Filter pass rate (filtered/total)
- Duplicate detection rate

## Troubleshooting

### No articles ingested
- Check sources exist: `/system/sources/{metroId}`
- Verify `active: true` on sources
- Check RSS URL is valid and returns recent items
- Review logs for fetch errors

### Too many duplicates
- RSS feed may be returning old items
- Check `pubDate` field in RSS items
- Consider adjusting hash algorithm

### Wrong metro timezone
- Verify `timeZone` in `schedules.ts` matches metro
- Check Firestore `/metros/{id}` has correct timezone

### Articles not showing in Today feed
- Verify `publishedAt` is recent (within 5am window)
- Check `status === "published"`
- Confirm `metroId` matches user's selected metro
- Today feed limit is **5 articles** (by design)

## ToS Compliance

✅ **We comply** by:
- Only storing headline, summary, and link
- Never storing full article body (`body: ""`)
- Opening articles externally via `sourceUrl`
- Using official RSS/API feeds only

❌ **Never**:
- Scrape full article content
- Display full articles in-app
- Republish content as our own
- Use unofficial scraping methods

## Testing RSS Ingestion

### 1. Start Emulators

```bash
firebase emulators:start
```

### 2. Seed RSS Sources

```bash
cd tool
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node seed_sources.ts
```

This creates placeholder sources in `/system/sources/{metro}/sources`.

**IMPORTANT**: Update placeholder URLs with real RSS feeds and set `active: true`.

### 3. Manual Trigger

```bash
curl "http://localhost:5001/brightside-9a2c5/us-central1/testIngest?metro=slc"
```

Expected response:
```json
{
  "success": true,
  "metro": "slc",
  "articlesIngested": 5,
  "message": "Successfully ingested 5 articles for slc"
}
```

### 4. Verify in Firestore

Open Firestore Emulator UI: http://localhost:4000

Navigate to `/articles` collection and verify:
- New documents with `metro_id: "slc"`
- `status: "published"`
- `source_url` from RSS feeds
- Recent `publish_time`

### 5. Verify in Flutter App

```bash
flutter run
```

1. Go to **Today** tab
2. Should show ≤5 recent SLC articles
3. Tap article → opens `source_url` externally

### 6. Check Health Monitoring

In Flutter (debug mode):
1. **Settings** → **Developer** → **[DEBUG] System Health**
2. Expand **SLC**
3. Verify: `Ingest: <recent timestamp>`

## Implementation Status

✅ RSS parser (`rss_parser.ts`)
✅ Positivity filter (`positivity_filter.ts`)
✅ Content normalizer (`content_normalizer.ts`)
✅ Main orchestrator (`runIngest.ts`)
✅ SLC scheduler (04:40 MT daily)
✅ Health monitoring
✅ Manual test trigger (`testIngest`)
✅ Seed script (`tool/seed_sources.ts`)

⏭️ Add real RSS URLs for SLC
⏭️ Enable NYC/GSP schedulers after testing

## Next Steps

1. Find good RSS sources for SLC (local news, community blogs)
2. Update URLs in Firestore and set `active: true`
3. Run manual test: `curl http://localhost:5001/.../testIngest?metro=slc`
4. Verify articles appear in Today feed
5. Monitor for 1 week, adjust filter keywords as needed
6. Repeat for NYC and GSP
