# APNs Verification Guide

Complete guide to verify push notifications on iOS devices using TestFlight.

**Last Updated:** 2025-01-06

---

## Overview

BrightSide uses Firebase Cloud Messaging (FCM) with APNs (Apple Push Notification service) for iOS notifications. This guide covers:

1. **Test Push** - Immediate verification using dev-only button
2. **Daily Digest** - Scheduled 7 AM local time notification
3. **Topic Subscriptions** - Metro-specific notification routing

---

## Prerequisites

### 1. APNs Key Configuration

Ensure APNs authentication key is uploaded to Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com) → BrightSide project
2. Navigate to **Project Settings** → **Cloud Messaging** tab
3. Verify **Apple app configuration** section shows:
   - ✅ APNs Authentication Key uploaded
   - ✅ Key ID displayed
   - ✅ Team ID displayed

**If missing:**
- Follow `/docs/PUSH_NOTIFICATIONS_IOS_SETUP.md` to generate and upload APNs key
- Wait 5-10 minutes for Firebase to propagate the key

### 2. TestFlight Build

Build and upload to TestFlight:

```bash
# 1. Build production release
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true --release

# 2. Open Xcode and archive
open ios/Runner.xcworkspace

# 3. In Xcode:
#    - Product → Archive
#    - Upload to App Store Connect
#    - Wait for processing (~5-10 min)
```

### 3. Physical iPhone Required

- **Simulator does NOT support push notifications**
- Use physical iPhone with TestFlight installed
- Device must have active internet connection

---

## Test 1: Immediate Test Push (Dev Only)

Verifies FCM token registration and APNs delivery.

### Steps

1. **Install TestFlight build** on physical iPhone
2. **Launch app** and complete onboarding:
   - Select metro (e.g., Salt Lake City)
   - View Today feed
   - Grant notification permission when prompted
3. **Navigate to Settings** → scroll down
4. **Look for debug section** (only visible in dev builds with `--dart-define=PROD=false`)
5. **Tap "Send test notification"**
6. **Verify immediate delivery**:
   - ✅ Toast shows "Test notification sent (1 sent, 0 failed)"
   - ✅ Notification appears in notification center
   - ✅ Banner shows: "🧪 BrightSide Test Notification"
   - ✅ Body: "Hey [name]! Your notifications are working perfectly. ✓"

### Expected Behavior

- **Success:** Notification arrives within 1-2 seconds
- **Failure:** Toast shows "No devices registered" → FCM token not saved

### Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Button not visible | Production build | Use dev build: `--dart-define=PROD=false` |
| "No devices registered" | FCM token not saved | Check Firestore: `/users/{uid}/devices` should have entry |
| "Permission denied" | No notification permission | Re-grant in iOS Settings → BrightSide → Notifications |
| "Test notification sent" but no banner | APNs key issue | Verify APNs key in Firebase Console |

### Debug Commands

```bash
# Check FCM token in Firestore (requires Firebase CLI + emulator)
firebase firestore:get /users/{uid}/devices --project brightside-9a2c5

# Expected output:
# {
#   "fcm_token": "e8kL3...",
#   "platform": "ios",
#   "created_at": "2025-01-06T...",
#   "app_version": "1.0.0"
# }
```

---

## Test 2: Daily Digest (7 AM Local Time)

Verifies scheduled Cloud Function and topic-based delivery.

### Setup

1. **Enable notifications** in app Settings
2. **Verify metro selection** (determines topic subscription)
3. **Verify topic subscription**:
   - Topic format: `metro_{metroId}_daily`
   - Example: `metro_slc_daily` for Salt Lake City
   - Check Firebase Console → Cloud Messaging → Topics

### Scheduled Delivery

Daily digest runs at **7:00 AM local time** per metro timezone:

| Metro | Timezone | UTC Time | Cron Schedule |
|-------|----------|----------|---------------|
| SLC | America/Denver (MST/MDT) | 14:00/13:00 | `0 14 * * *` (winter)<br>`0 13 * * *` (summer) |
| NYC | America/New_York (EST/EDT) | 12:00/11:00 | `0 12 * * *` (winter)<br>`0 11 * * *` (summer) |
| GSP | America/New_York (EST/EDT) | 12:00/11:00 | Same as NYC |

**Note:** Actual cron uses single UTC time - may need adjustment for DST.

### Expected Notification

At 7 AM local time:

- **Title:** "🌅 Your Daily BrightSide"
- **Body:** "3 uplifting stories from [Metro Name] await you today"
- **Data:**
  - `type: "daily_digest"`
  - `metro_id: "slc"`
  - `article_count: 3`
- **Tap behavior:** Opens Today feed

### Verification Steps

1. **Wait for 7 AM** local time
2. **Check notification arrives** (~7:00-7:02 AM)
3. **Tap notification** → app opens to Today feed
4. **Verify articles** are from today (published after 5 AM)

### Manual Test (Without Waiting)

Use Firebase Functions emulator or production callable:

```bash
# 1. Start emulator
firebase emulators:start --only functions,firestore

# 2. Trigger digest manually
firebase functions:shell
> digestSlc()  # Or digestNyc(), digestGsp()

# 3. Check logs for topic publish
# Look for: "Published to topic: metro_slc_daily"
```

### Troubleshooting Daily Digest

| Issue | Cause | Fix |
|-------|-------|-----|
| No notification at 7 AM | Scheduler not deployed | Deploy functions: `firebase deploy --only functions` |
| Wrong metro stories | Topic subscription issue | Check user subscribed to correct topic |
| Notification missing articles | Ingestion failed | Check Cloud Scheduler ran at 5 AM |
| Multiple notifications | Subscribed to multiple topics | Unsubscribe from old metros |

---

## Test 3: Metro Change & Topic Re-subscription

Verifies topic subscription updates when user changes metro.

### Steps

1. **Initial setup:**
   - Enable notifications in Settings
   - Select metro "Salt Lake City"
   - Verify subscribed to `metro_slc_daily`

2. **Change metro:**
   - Go to Settings → Your Metro
   - Select "New York City"
   - Confirm change

3. **Verify topic update:**
   - Should auto-unsubscribe from `metro_slc_daily`
   - Should auto-subscribe to `metro_nyc_daily`

4. **Wait for next 7 AM NYC time** or trigger manually

5. **Verify NYC digest arrives** (not SLC)

### Code Flow

```dart
// When metro changes in metro_provider.dart:
await _setMetro(newMetroId);
  └─> notificationNotifier.updateMetroSubscription(newMetroId)
      └─> unsubscribeFromMetroTopic(oldMetro)
      └─> subscribeToMetroTopic(newMetro)
```

### Verification

```bash
# Check current subscriptions in FCM
# (Via Firebase Console → Cloud Messaging → Topics)

# Expected:
# metro_nyc_daily: 1 device (after change)
# metro_slc_daily: 0 devices
```

---

## Test 4: Notification Toggle

Verifies subscribe/unsubscribe on notification opt-in toggle.

### Steps

1. **Toggle OFF:**
   - Settings → Notifications → Toggle OFF
   - Confirms unsubscribe from current metro topic

2. **Verify no digest:**
   - Wait for 7 AM
   - Should NOT receive notification

3. **Toggle ON:**
   - Settings → Notifications → Toggle ON
   - Confirms subscribe to current metro topic

4. **Verify digest resumes:**
   - Next 7 AM should receive notification

### Code Flow

```dart
// In notification_provider.dart:
toggleNotifications(enabled)
  └─> if (enabled) {
        subscribeToMetroTopic(currentMetro);
      } else {
        unsubscribeFromMetroTopic(currentMetro);
      }
```

---

## Production Verification Checklist

Before App Store release:

- [ ] **APNs Key:** Verify uploaded in Firebase Console
- [ ] **Test Push:** Immediate delivery works on TestFlight
- [ ] **Daily Digest:** 7 AM notification arrives on physical device
- [ ] **Metro Change:** Topic re-subscription works
- [ ] **Toggle:** ON/OFF controls digest delivery
- [ ] **Tap Behavior:** Notification opens correct screen (Today feed)
- [ ] **Analytics:** `notif_open` event fires on tap
- [ ] **Permissions:** App requests notification permission after first feed view
- [ ] **Device Token:** Saved to `/users/{uid}/devices` on permission grant
- [ ] **Cleanup:** Token deleted on account deletion

---

## Debug Tools

### 1. Test Push Function

**Location:** `functions/src/notifications/sendTestPush.ts`

**Usage:**
```typescript
// Cloud Function callable
sendTestPush({ targetUid?: string })

// Sends to caller's registered devices
// Admin-only: can target other users
```

**Button Location (Dev Only):**
- Settings → Developer section → "Send test notification"
- Only visible when `!Env.isProd && !kReleaseMode`

### 2. Check Device Tokens

```bash
# Firestore query
firebase firestore:get /users/{uid}/devices --project brightside-9a2c5

# Expected structure:
{
  "{device_id}": {
    "fcm_token": "e8kL3mN...",
    "platform": "ios",
    "app_version": "1.0.0",
    "created_at": Timestamp,
    "last_seen_at": Timestamp
  }
}
```

### 3. Check Topic Subscriptions

Firebase Console → Cloud Messaging → Topics:
- `metro_slc_daily`
- `metro_nyc_daily`
- `metro_gsp_daily`

Each should show subscriber count.

### 4. Monitor Cloud Functions Logs

```bash
# Real-time logs
firebase functions:log --only digestSlc,digestNyc,digestGsp

# Filter for errors
firebase functions:log --only digestSlc | grep ERROR
```

---

## Common Issues

### "No devices registered"
- **Cause:** FCM token not saved to Firestore
- **Fix:** Re-grant notification permission, check `/users/{uid}/devices`

### "Test notification sent" but no banner
- **Cause:** APNs key not configured or invalid
- **Fix:** Verify APNs key in Firebase Console → Cloud Messaging

### Daily digest not arriving
- **Cause:** Cloud Scheduler not deployed or topic subscription missing
- **Fix:**
  1. `firebase deploy --only functions`
  2. Check topic subscription in Firebase Console

### Notification arrives but tap does nothing
- **Cause:** Routing logic issue in `main_prod.dart`
- **Fix:** Verify `_handleNotificationRoute()` processes `data['route']` correctly

### Multiple digests from different metros
- **Cause:** User subscribed to multiple metro topics
- **Fix:** Ensure `updateMetroSubscription()` unsubscribes from old metro

---

## Analytics Verification

After testing, verify analytics events:

```bash
# Firebase Console → Analytics → Events

# Expected events:
1. app_open        # On launch
2. metro_set       # On metro selection
3. notif_open      # On notification tap
4. article_open    # On article view from notification
```

**Production builds should ONLY log these 4 events.**

---

## Related Documentation

- [Push Notifications Setup](./PUSH_NOTIFICATIONS_IOS_SETUP.md) - APNs key generation
- [Daily Digest Summary](../DAILY_DIGEST_SUMMARY.md) - Digest implementation details
- [Settings Screen](../lib/features/settings/settings_screen.dart) - Test push button
- [Notification Provider](../lib/features/notifications/providers/notification_provider.dart) - Topic subscription logic

---

**Last Verified:** 2025-01-06
**Next Review:** Before App Store submission
