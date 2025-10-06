# QA Health Check Guide

This guide helps verify the health monitoring system is working correctly.

## Health Ping System

### Backend (Cloud Functions)

Health pings are automatically recorded after each scheduler run:

- **Ingest schedulers** (04:40 local time per metro)
  - `ingestSlc` → writes `system/health/slc.lastIngestAt`
  - `ingestNyc` → writes `system/health/nyc.lastIngestAt`
  - `ingestGsp` → writes `system/health/gsp.lastIngestAt`

- **Digest schedulers** (07:00 local time per metro)
  - `digestSlc` → writes `system/health/slc.lastDigestAt`
  - `digestNyc` → writes `system/health/nyc.lastDigestAt`
  - `digestGsp` → writes `system/health/gsp.lastDigestAt`

### Frontend (Flutter Debug UI)

In debug mode, Settings → Developer section shows:
- **[DEBUG] System Health** (expandable tile)
- Per-metro health indicators showing last ingest and digest times
- Real-time updates via Firestore stream

## Testing Health System

### 1. Manual Test (Local Emulators)

```bash
# Start Firebase emulators
cd functions
firebase emulators:start

# In another terminal, trigger a scheduler manually (if supported)
# Or write test data to Firestore:
```

Write test health data:
```javascript
// In Firestore emulator UI (http://localhost:4000)
// Collection: system
// Document: health
{
  "slc": {
    "lastIngestAt": <current timestamp>,
    "lastDigestAt": <current timestamp>,
    "status": "ok"
  },
  "nyc": {
    "lastIngestAt": <current timestamp>,
    "lastDigestAt": <current timestamp>,
    "status": "ok"
  },
  "gsp": {
    "lastIngestAt": <current timestamp>,
    "lastDigestAt": <current timestamp>,
    "status": "ok"
  }
}
```

### 2. Verify in Flutter App

1. Run app in debug mode: `flutter run`
2. Navigate to Settings tab
3. Scroll to Developer section
4. Tap on **[DEBUG] System Health**
5. Verify:
   - Each metro (SLC, NYC, GSP) shows ingest and digest times
   - Times update when you modify Firestore data
   - "Never" appears if no data exists

### 3. Production Verification

After deploying Cloud Functions:

1. Wait for first scheduler run (04:40 or 07:00 local time)
2. Check Firestore console → `system/health` document
3. Verify timestamps are recent
4. Check app Debug section shows correct times

## Expected Behavior

### Success Indicators

✅ Health document exists at `/system/health`
✅ Each metro has `lastIngestAt` and `lastDigestAt` fields
✅ Timestamps update after each scheduler run
✅ App displays formatted times (e.g., "Jan 3, 4:45 AM")
✅ Times are within expected range (recent)

### Failure Indicators

❌ No health document exists → Schedulers not running
❌ Timestamps are stale (>24h old) → Silent scheduler failures
❌ Missing metro data → Specific metro scheduler broken
❌ App shows "Never" for all metros → Firestore rules issue or no data

## Integration Tests

Run the full integration test suite:

```bash
# Start emulators
firebase emulators:start

# Run tests
flutter test integration_test/core_flows_test.dart
```

Tests cover:
1. First run flow (location → metro picker → feed)
2. Authentication → user creation
3. Story submission → Firestore persistence
4. Like/unlike → state persistence
5. Metro switching → feed refresh performance

## Performance Profiling

Check frame rendering performance:

```bash
# Run in profile mode
flutter run --profile

# Manually scroll Today and Popular feeds
# Check for smooth 60fps (no yellow/red frames)
```

Use DevTools for detailed profiling:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Target:** <16ms per frame (60fps)
**Warning:** >16ms (yellow frames)
**Error:** >33ms (red frames)

## Troubleshooting

### Health data not appearing

1. Check Cloud Functions logs:
   ```bash
   firebase functions:log
   ```

2. Look for "Health ping recorded" messages

3. Verify Firestore rules allow writes to `/system/health`:
   ```
   match /system/{document=**} {
     allow write: if true; // Cloud Functions write
     allow read: if request.auth != null; // Authenticated users read
   }
   ```

### App shows "Never" for all metros

1. Verify you're in debug mode (release builds hide this UI)
2. Check Firestore connection (are other features working?)
3. Verify `/system/health` document exists in Firestore
4. Check auth state (StreamBuilder requires data)

### Timestamps are incorrect

1. Verify server timezone settings in schedulers
2. Check client device timezone
3. DateFormat uses device locale - verify intl package setup
