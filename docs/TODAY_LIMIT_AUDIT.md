# Today Feed Limit Audit (5 Stories Maximum)

Comprehensive audit of the 5-story limit enforcement across BrightSide.

**Date:** 2025-01-06  
**Limit:** ≤5 stories per day per metro

---

## ✅ System Configuration

### Firestore Config
- **File:** `tool/seed_system_config.ts:30`
- **Value:** `today_max_articles: 5`
- **Status:** ✅ Updated

### Flutter Default Config
- **File:** `lib/core/services/system_config.dart:27`
- **Value:** `todayMaxArticles: 5`
- **Status:** ✅ Updated

### Environment Check
- **File:** `tool/print_env_check.ts:65`
- **Fallback:** `|| 5`
- **Status:** ✅ Updated

---

## ✅ Backend (Cloud Functions)

### Ingestion Limit
- **File:** `functions/src/ingest/runIngest.ts:200-218`
- **Logic:** `remainingSlots = Math.max(0, 5 - existingToday)`
- **Log:** `Daily limit reached for ${metroId} (5 articles)`
- **Status:** ✅ Enforced at ingestion

### Comment Documentation
- **File:** `functions/src/ingest.ts:190`
- **Comment:** `Limits to 5 articles per day per metro`
- **Status:** ✅ Updated

---

## ✅ Frontend (Flutter)

### Today Query
- **File:** `lib/features/story/data/story_repository_firebase.dart:49`
- **Query:** `.limit(5)`
- **Window:** `publishedAt >= startOf5AMWindow`
- **Status:** ✅ Enforced in query

### Popular Query
- **File:** `lib/features/story/data/story_repository_firebase.dart:96, 118`
- **Queries:** `.limit(5)` and `.limit(5 - featured.length)`
- **Status:** ✅ Capped at 5 total (featured + popular)

### Schema Constants
- **File:** `lib/backend/schema_constants.dart:27, 58`
- **Queries:** `.limit(5)` for today and submissions
- **Status:** ✅ All queries limited

---

## ✅ Tests

### Integration Test
- **File:** `integration_test/ingestion_today_test.dart:16, 170`
- **Comment:** `Verify feed respects daily limit (≤5 articles)`
- **Assert:** `expect(allArticles.docs.length, lessThanOrEqualTo(5))`
- **Status:** ✅ Test enforces limit

### Test README
- **File:** `integration_test/README.md:17`
- **Documentation:** `Verify daily limit (≤5 articles)`
- **Status:** ✅ Updated

---

## ✅ Documentation

### App Store Metadata
- **File:** `docs/app-store/metadata.md`
- **Description:** `Just 5 curated stories each day`
- **Features:** `5 curated uplifting stories daily`
- **Demo:** `Today feed shows 5 curated stories`
- **Status:** ✅ All references updated

### Screenshots Guide
- **File:** `docs/app-store/screenshots.md`
- **Description:** `showing 5 curated positive stories`
- **Screen State:** `Today feed with 5 stories loaded`
- **Caption:** `5 Uplifting Stories Curated Daily`
- **Status:** ✅ All references updated

### Preflight Checklist
- **File:** `docs/checklists/preflight.md`
- **Test:** `5 stories appear (or fewer if not enough curated)`
- **Window:** `Story count resets to ≤5`
- **Critical Path:** `Today feed (5 stories, 5 AM window)`
- **Status:** ✅ All references updated

### Checklists Index
- **File:** `docs/checklists/README.md`
- **Summary:** `Today feed (5 stories, 5 AM cutoff)`
- **Status:** ✅ Updated

### Preflight Summary
- **File:** `PREFLIGHT_SUMMARY.md`
- **Test:** `5 stories appear (or max available)`
- **Status:** ✅ Updated

---

## 🔍 Verification Commands

### Check System Config
```bash
# Verify Firestore config
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts | grep "Max Articles"

# Expected: Max Articles (Today): 5
```

### Check Code References
```bash
# Search for any remaining limit(8) references
grep -rn "limit(8)\|limit.*8" lib/ functions/src/ --include="*.dart" --include="*.ts" | grep -v node_modules

# Expected: No results (or only unrelated references)
```

### Check Documentation
```bash
# Search for "8 stories" or "8 curated" references
grep -r "8 stories\|8 curated" docs/ --include="*.md"

# Expected: No results
```

---

## 📊 Limit Enforcement Flow

### 1. Ingestion (Backend)
```
RSS Feed → runIngest() → Check daily limit (5 max) → Write to Firestore
```

- **Enforcement Point:** `functions/src/ingest/runIngest.ts:213`
- **Logic:** `remainingSlots = Math.max(0, 5 - existingToday)`
- **Behavior:** Stops ingesting after 5 articles per metro per day

### 2. Query (Frontend)
```
Today Screen → fetchToday() → Query with limit(5) → Display stories
```

- **Enforcement Point:** `lib/features/story/data/story_repository_firebase.dart:49`
- **Query:** `.limit(5)` + `publishedAt >= 5AM window`
- **Behavior:** Never returns more than 5 stories

### 3. UI Display (Frontend)
```
Today Screen → StoryList → Render stories → Max 5 visible
```

- **Natural Cap:** Query only returns ≤5 stories
- **No UI Cap Needed:** List naturally displays what query returns

---

## 🚨 Critical Invariants

**The following must ALWAYS be true:**

1. ✅ **Firestore Config:** `today_max_articles = 5`
2. ✅ **Ingestion Limit:** `remainingSlots = 5 - existingToday`
3. ✅ **Query Limit:** `.limit(5)` in fetchToday()
4. ✅ **Window Check:** `publishedAt >= startOf5AMWindow`
5. ✅ **Integration Test:** `lessThanOrEqualTo(5)`

**If any of these are violated, the 5-story limit is not enforced.**

---

## 🔄 5 AM Window Logic

The Today feed shows articles published since the most recent 5 AM local time.

### Window Calculation
```dart
// If current time is before 5 AM → use 5 AM yesterday
// If current time is 5 AM or later → use 5 AM today

final now = tz.TZDateTime.now(location);
var fiveAmToday = tz.TZDateTime(location, now.year, now.month, now.day, 5, 0, 0);

if (now.isBefore(fiveAmToday)) {
  fiveAmToday = fiveAmToday.subtract(const Duration(days: 1));
}

return fiveAmToday.toUtc();
```

### Examples

**Scenario 1: 4:30 AM MST (SLC)**
- Window: 5 AM yesterday MST → 4:30 AM today MST
- Shows: Yesterday's stories (published between 5 AM yesterday and now)

**Scenario 2: 7:00 AM MST (SLC)**
- Window: 5 AM today MST → now
- Shows: Today's stories (published after 5 AM today)

**Scenario 3: Timezone Change**
- User switches metro → window recalculates for new timezone
- Stories refresh based on new metro's 5 AM local time

---

## 📝 Manual Verification Checklist

Before deployment:

- [ ] Run `npx ts-node tool/seed_system_config.ts` (sets today_max_articles: 5)
- [ ] Verify `npx ts-node tool/print_env_check.ts` shows "Max Articles (Today): 5"
- [ ] Build release: `flutter build ios --release`
- [ ] Test on device: Launch app, verify Today feed shows ≤5 stories
- [ ] Test window: Before 5 AM, verify shows yesterday's stories
- [ ] Test window: After 5 AM, verify shows today's stories
- [ ] Test limit: Seed 10 stories, verify only 5 appear in Today feed
- [ ] Test refresh: Pull-to-refresh Today feed, still shows ≤5 stories

---

## 🛠️ Troubleshooting

### Issue: Today feed shows >5 stories

**Possible Causes:**
1. System config not seeded (run `npx ts-node tool/seed_system_config.ts`)
2. Query limit not applied (check `story_repository_firebase.dart:49`)
3. Ingestion limit not enforced (check `runIngest.ts:213`)

**Debug Steps:**
```bash
# 1. Check Firestore config
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts

# 2. Check Firestore articles count
# (In Firestore Console, filter by metro_id and publishedAt >= 5AM today)

# 3. Check app logs for query
# Look for "Fetched X articles" in debug logs
```

### Issue: Today feed shows 0 stories

**Possible Causes:**
1. No articles ingested yet (run ingestion function)
2. All articles older than 5 AM window (check publishedAt timestamps)
3. Articles in wrong status (must be "published")

**Debug Steps:**
```bash
# Check articles in Firestore
# Filter: metro_id == "slc" AND status == "published" AND publishedAt >= today 5AM
```

---

## 📚 Related Documentation

- [System Config](../core/services/system_config.dart) - Configuration model
- [Story Repository](../features/story/data/story_repository_firebase.dart) - Today query
- [Ingestion Logic](../../functions/src/ingest/runIngest.ts) - Daily limit enforcement
- [Integration Test](../../integration_test/ingestion_today_test.dart) - Limit verification

---

**Last Updated:** 2025-01-06  
**Audited By:** Claude Code  
**Status:** ✅ All references updated to 5 stories
