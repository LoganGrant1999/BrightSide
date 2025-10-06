# Daily Digest Push Notifications

Sends a "Good Morning" digest notification to users at 07:00 local time for each metro, featuring the top 3 articles from today's feed.

## Overview

The daily digest system:
- Runs at **07:00 local time** for each metro (SLC, NYC, GSP)
- Queries top 3 articles from today's 5am rolling window
- Sends FCM push notification to topic `metro_{metroId}_daily`
- Routes to Today tab, optionally opening article detail
- Logs `notif_open` analytics event on tap
- Only sends if articles are available

## Architecture

```
Scheduler (07:00 local)
    ↓
sendDigestToTopic(metroId)
    ↓
getTodayTopN(metroId, 3)
    ↓
buildPayload(metroId, articles)
    ↓
FCM Topic: metro_{metroId}_daily
    ↓
User devices with opt-in
    ↓
Tap notification → Analytics → Route to /today (+ optional /story/:id)
```

## Functions

### `dailyDigest.ts`

**getTodayTopN(metroId, n=3)**
- Queries articles where:
  - `metroId == metroId`
  - `status == "published"`
  - `publishedAt >= 5am local window`
- Orders by `publishedAt desc`
- Returns top N documents

**buildPayload(metroId, articles)**
- Notification title: "Your BrightSide stories are ready ☀️"
- Notification body: Top headline + article count
- Data payload:
  ```typescript
  {
    route: "/today",
    metroId: string,
    articleId?: string  // ID of top article if available
  }
  ```
- Platform-specific config:
  - iOS: sound, badge
  - Android: high priority, daily_digest channel

**sendDigestToTopic(metroId)**
- Gets top 3 articles
- Skips if no articles found
- Builds and sends FCM message to topic
- Logs success/failure

### `schedules.ts` - Digest Schedulers

**digestSlc**
- Schedule: `0 7 * * *` (07:00 daily)
- Timezone: `America/Denver`

**digestNyc**
- Schedule: `0 7 * * *` (07:00 daily)
- Timezone: `America/New_York`

**digestGsp**
- Schedule: `0 7 * * *` (07:00 daily)
- Timezone: `America/New_York`

## Client Implementation (Flutter)

### Topic Subscription

**When user enables notifications:**
```dart
// Subscribes to metro_${metroId}_daily
await notificationService.subscribeToMetroTopic(metroId);
```

**When user changes metro:**
```dart
// Unsubscribes from old, subscribes to new
await notificationProvider.updateMetroSubscription(newMetroId);
```

**When user disables notifications:**
```dart
// Unsubscribes from topic
await notificationService.unsubscribeFromMetroTopic(metroId);
```

### Notification Routing

**Handled in `main.dart`:**

```dart
void _handleNotificationRoute(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  final articleId = data['articleId'] as String?;

  if (route == '/today') {
    router.go('/today');

    // If articleId present, open detail
    if (articleId != null && articleId.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        router.push('/story/$articleId');
      });
    }
  }
}
```

**Analytics logged:**
- `notif_open` event with `metroId`
- Called in `notification_service.dart:_handleNotificationTap()`

### Settings UI

**Notification Settings Page** (`notification_settings_page.dart`):
- ✅ Shows permission status
- ✅ Request permission button
- ✅ Daily digest toggle (on/off)
- ✅ Displays current metro
- ✅ Shows notification time (7:00 AM)
- ✅ Info about digest content

**User Flow:**
1. User navigates to Settings → Notifications
2. If no permission: Shows "Enable Notifications" button
3. Tap → Request iOS/Android permission
4. If granted: Shows toggle switch
5. Toggle ON → Subscribes to `metro_{metroId}_daily` topic
6. Toggle OFF → Unsubscribes from topic

## Testing

### Local Testing (Emulator)

**Note:** FCM cannot send real notifications to emulator, but you can verify logic:

```bash
# Terminal 1: Start emulators
cd functions
npm run serve

# Terminal 2: Create test articles
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_ingest.ts slc

# Terminal 3: Test digest logic
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node test_digest.ts slc
```

Output shows:
- ✓ Articles fetched
- ✓ Payload built correctly
- ⚠️ Cannot send in emulator (expected)

### Production Testing

**1. Deploy functions:**
```bash
firebase deploy --only functions:digestSlc,functions:digestNyc,functions:digestGsp
```

**2. Test with adjusted schedule:**

Edit `schedules.ts` temporarily:
```typescript
// Change from "0 7 * * *" to 5 minutes from now
// Example: If it's 14:30, use "35 14 * * *"
schedule: "35 14 * * *",  // Runs at 14:35
```

Redeploy:
```bash
firebase deploy --only functions:digestSlc
```

**3. Subscribe test device:**

In Flutter app:
- Sign in
- Go to Settings → Notifications
- Enable notifications
- Verify metro is set to "slc"

Device auto-subscribes to `metro_slc_daily` topic.

**4. Wait for trigger:**
- Wait until scheduled time (14:35 in example)
- Notification should arrive on device
- Tap notification → Should open Today tab
- If articleId present → Should open article detail

**5. Verify analytics:**

Check Firebase Analytics console:
- `notif_open` event with `metro_id: slc`

**6. Reset schedule:**
```typescript
// Restore to 07:00
schedule: "0 7 * * *",
```

### Manual Trigger (Testing)

You can also trigger manually via Firebase console or CLI:

```bash
# Using gcloud CLI
gcloud scheduler jobs run digestSlc --location=us-central1

# Or via Firebase console:
# Cloud Functions → digestSlc → Testing tab → Run function
```

## Data Flow

### Notification Payload Example

```json
{
  "topic": "metro_slc_daily",
  "notification": {
    "title": "Your BrightSide stories are ready ☀️",
    "body": "Local artist creates mural for community • 3 stories today"
  },
  "data": {
    "route": "/today",
    "metroId": "slc",
    "articleId": "abc123def456"
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "default",
        "badge": 1
      }
    }
  },
  "android": {
    "priority": "high",
    "notification": {
      "channelId": "daily_digest",
      "priority": "high",
      "defaultSound": true
    }
  }
}
```

### User Preference Storage

**Firestore `/users/{uid}`:**
```typescript
{
  notification_opt_in: boolean,  // Controls digest subscription
  chosen_metro: string,          // Determines which topic to subscribe to
  // ... other user fields
}
```

**Device Token Storage `/users/{uid}/devices/{deviceId}`:**
```typescript
{
  fcm_token: string,
  apns_token?: string,
  platform: "ios" | "android",
  app_version: string,
  last_seen: Timestamp
}
```

## Acceptance Criteria ✅

- [x] Daily digest sent at 07:00 local time per metro
- [x] Only sends if articles are available (3-8 from today's window)
- [x] Notification title: "Your BrightSide stories are ready ☀️"
- [x] Body shows top headline + article count
- [x] Tap opens Today tab
- [x] If articleId present, opens article detail after navigation
- [x] Logs `notif_open` analytics event
- [x] Settings toggle controls subscription
- [x] Toggle OFF prevents delivery (unsubscribes from topic)
- [x] Metro change updates topic subscription
- [x] FCM/APNS configured with sound and badge

## Troubleshooting

### No notification received

**Check device subscription:**
```dart
// In Flutter app logs, look for:
// "Subscribed to topic: metro_slc_daily"
```

**Verify in Firebase:**
- Console → Cloud Messaging
- Check if topic `metro_slc_daily` exists
- View estimated subscribers

**Check function logs:**
```bash
firebase functions:log --only digestSlc
```

Look for:
- "Starting daily digest for metro: slc"
- "Found X articles for slc"
- "Successfully sent digest"

### Notification received but doesn't route

**Check Flutter logs:**
- Look for "Notification tapped: ..."
- Verify `route` and `articleId` in data payload

**Verify navigation:**
- Ensure router is initialized
- Check `main.dart:_handleNotificationRoute()`

### Wrong metro notifications

**Check user's metro:**
```dart
// In app, verify Settings → Metro shows correct city
```

**Check topic subscription:**
- Should match current metro: `metro_{chosenMetro}_daily`
- Old subscriptions cleared when metro changes

### Articles not in digest

**Check 5am window:**
- Articles must be published >= 5am local time
- If before 5am, uses 5am yesterday

**Verify article query:**
```typescript
// Should return articles where:
// - metroId == 'slc'
// - status == 'published'
// - publishedAt >= windowStart
```

## Monitoring

**Key Metrics:**
- Topic subscriber count (Firebase Console → Cloud Messaging)
- Digest send success rate (Cloud Functions logs)
- `notif_open` event rate (Analytics)
- Notification permission grant rate
- Daily digest toggle on/off rate

**Alerts to Set:**
- Digest function errors > 5% (indicates topic issues)
- Zero articles found for metro (ingestion problem)
- `notif_open` rate < 10% (engagement issue)

## Production Schedule

| Metro | Timezone | Schedule | UTC Equivalent |
|-------|----------|----------|----------------|
| SLC | America/Denver | 07:00 | ~14:00 UTC (DST) / ~15:00 UTC |
| NYC | America/New_York | 07:00 | ~12:00 UTC (DST) / ~13:00 UTC |
| GSP | America/New_York | 07:00 | ~12:00 UTC (DST) / ~13:00 UTC |

**Note:** NYC and GSP run in same timezone, so they trigger at same UTC time.

## Future Enhancements

- [ ] Personalized digest based on user interests
- [ ] Weekend vs weekday schedules
- [ ] Customizable notification time (per user)
- [ ] Rich notifications with images
- [ ] In-app notification history
- [ ] A/B test notification copy
- [ ] Delivery time optimization based on open rates

---

**Status:** ✅ Production ready

**Last Updated:** 2025-10-03
