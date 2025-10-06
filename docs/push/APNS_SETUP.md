# APNs (Apple Push Notification Service) Setup

Complete guide for configuring Apple Push Notifications for BrightSide iOS production builds.

---

## Prerequisites

- **Apple Developer Account** (paid membership required)
- **Firebase Project** (production)
- **Bundle ID** registered in Apple Developer Console
- **Xcode** with BrightSide iOS project

---

## Part 1: Create APNs Auth Key

### Step 1: Access Apple Developer Console

1. Go to [Apple Developer Console](https://developer.apple.com/account)
2. Sign in with your Apple Developer account
3. Navigate to **Certificates, Identifiers & Profiles**

### Step 2: Create APNs Authentication Key

1. In the left sidebar, click **Keys**
2. Click the **+** (plus) button to create a new key
3. Configure the key:
   - **Key Name:** `BrightSide APNs Key` (or similar)
   - **Key Services:** Check **Apple Push Notifications service (APNs)**
4. Click **Continue**
5. Click **Register**

### Step 3: Download the Key

⚠️ **IMPORTANT:** You can only download the key **once**. Store it securely.

1. Click **Download** to download the `.p8` file
   - Example filename: `AuthKey_ABC123XYZ.p8`
2. **Note the Key ID** (10-character string)
   - Example: `ABC123XYZ`
3. **Note the Team ID** (found in top-right of Apple Developer portal)
   - Example: `DEF456UVW`
4. Click **Done**

**Save these values:**
```
Key ID:   ABC123XYZ
Team ID:  DEF456UVW
Key File: AuthKey_ABC123XYZ.p8
```

---

## Part 2: Verify Bundle ID

### Step 1: Check Bundle ID in Apple Developer

1. In Apple Developer Console, go to **Identifiers**
2. Find your app's Bundle ID: `com.brightside.app` (or your actual Bundle ID)
3. Click on it to view details
4. Ensure **Push Notifications** capability is enabled
   - If not enabled, check the box and click **Save**

### Step 2: Verify Bundle ID in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Verify **Bundle Identifier** matches: `com.brightside.app`
5. Ensure **Push Notifications** capability is added:
   - If not, click **+ Capability** and add **Push Notifications**

### Step 3: Verify in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **production** project
3. Go to **Project Settings** (gear icon) → **General**
4. Scroll to **Your apps** section
5. Find your iOS app
6. Verify **Bundle ID** matches: `com.brightside.app`

---

## Part 3: Upload APNs Key to Firebase

### Step 1: Access Firebase Cloud Messaging Settings

1. In Firebase Console, select your **production** project
2. Go to **Project Settings** (gear icon) → **Cloud Messaging** tab
3. Scroll to **Apple app configuration** section

### Step 2: Upload APNs Authentication Key

1. Under **APNs authentication key**, click **Upload**
2. Configure the key:
   - **Key File:** Click **Browse** and select your `.p8` file (e.g., `AuthKey_ABC123XYZ.p8`)
   - **Key ID:** Enter the 10-character Key ID (e.g., `ABC123XYZ`)
   - **Team ID:** Enter your Apple Developer Team ID (e.g., `DEF456UVW`)
3. Click **Upload**

### Step 3: Verify Upload

You should see:
```
✓ APNs authentication key uploaded
Key ID: ABC123XYZ
Team ID: DEF456UVW
```

---

## Part 4: Configure iOS Project

### Step 1: Enable Push Notifications Capability

**In Xcode:**

1. Open `ios/Runner.xcworkspace`
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Push Notifications**
6. Ensure it appears in the capabilities list

### Step 2: Enable Background Modes

1. In **Signing & Capabilities** tab
2. Click **+ Capability**
3. Add **Background Modes**
4. Check the following modes:
   - ✅ **Remote notifications**
   - ✅ **Background fetch** (optional, for silent notifications)

### Step 3: Verify Entitlements File

Check that `ios/Runner/Runner.entitlements` includes:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
	<!-- For production, this will be 'production' -->
</dict>
</plist>
```

**Note:** The `aps-environment` key is automatically set based on your build configuration:
- **Debug builds:** `development`
- **Release/Archive builds:** `production`

---

## Part 5: Firebase Configuration Files

### Step 1: Download GoogleService-Info.plist

1. In Firebase Console → **Project Settings** → **General**
2. Under **Your apps**, find your iOS app
3. Click the **Download GoogleService-Info.plist** button
4. Save the file

### Step 2: Replace in Xcode

1. In Xcode, locate the current `GoogleService-Info.plist` file
   - Path: `ios/Runner/GoogleService-Info.plist`
2. Delete the old file (Move to Trash)
3. Drag the new `GoogleService-Info.plist` into the **Runner** folder in Xcode
4. Ensure **Copy items if needed** is checked
5. Ensure **Target membership** includes **Runner**

### Step 3: Verify Configuration

Open `GoogleService-Info.plist` and verify:
```xml
<key>BUNDLE_ID</key>
<string>com.brightside.app</string>

<key>IS_ADS_ENABLED</key>
<false/>

<key>IS_ANALYTICS_ENABLED</key>
<true/>

<key>IS_APPINVITE_ENABLED</key>
<true/>

<key>IS_GCM_ENABLED</key>
<true/>
```

---

## Part 6: Test Push Notifications

### Local Testing (Debug Build)

**1. Run on Physical Device:**

```bash
flutter run -t lib/main_dev.dart --device-id <your-iphone-id>
```

⚠️ **Push notifications do NOT work in iOS Simulator** - you must use a physical device.

**2. Check Device Token:**

Look for log output:
```
📱 FCM Token: <long-token-string>
```

**3. Send Test Notification via Firebase Console:**

1. Go to Firebase Console → **Cloud Messaging**
2. Click **Send your first message**
3. Enter notification title and text
4. Click **Next**
5. Select **iOS app**
6. Target: **User segment** → **All users**
7. Click **Review** → **Publish**

### TestFlight Testing (Production Build)

**1. Create Archive:**

```bash
# Build production version
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true --release

# Open in Xcode
open ios/Runner.xcworkspace
```

**In Xcode:**
1. Select **Product** → **Archive**
2. Wait for archive to complete
3. Click **Distribute App**
4. Select **TestFlight & App Store**
5. Follow the prompts to upload to App Store Connect

**2. Invite TestFlight Testers:**

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Add **Internal Testers** or **External Testers**
5. Invite via email

**3. Install TestFlight Build:**

1. Testers receive email invitation
2. Install **TestFlight** app from App Store
3. Accept invitation and install BrightSide build
4. Launch app and grant notification permission

**4. Send Test Notification:**

In the app:
1. Go to **Settings**
2. Scroll to **Developer** section (if in dev mode)
3. Tap **Send test notification**

OR use the `sendTestPush` callable function:
```typescript
import { httpsCallable } from 'firebase/functions';

const sendTestPush = httpsCallable(functions, 'sendTestPush');
await sendTestPush();
```

---

## Part 7: Daily Digest Notification

### How It Works

**Scheduled Function** (`scheduleDailyDigest`):
- Runs daily at 7:00 AM local time for each metro
- Sends to FCM topic: `metro_{metroId}_daily`
- Only sends to users with `notification_opt_in: true` and matching `chosen_metro`

**Topic Subscription:**
- User subscribes when they:
  - Enable notifications in Settings
  - Set their chosen metro
- User unsubscribes when they:
  - Disable notifications
  - Change metro (unsub from old, sub to new)
  - Delete account

### Testing Daily Digest

**Manual Trigger (Functions Shell):**

```bash
cd functions
npm run shell

> scheduleDailyDigest({ metroId: 'slc' })
```

**Check Logs:**

```bash
firebase use prod
firebase functions:log --only scheduleDailyDigest
```

**Expected Log Output:**

```
📬 Sending daily digest for SLC to topic: metro_slc_daily
   Articles count: 8
   ✓ Notification sent successfully
```

---

## Troubleshooting

### Issue: "APNs device token not set"

**Cause:** Device token not registered with Firebase.

**Solution:**
1. Ensure app has notification permission granted
2. Check logs for FCM token registration
3. Verify `firebase_messaging` plugin is initialized
4. Restart app and check token again

### Issue: Notifications not received on physical device

**Checklist:**
- [ ] Push Notifications capability enabled in Xcode
- [ ] APNs Auth Key uploaded to Firebase Console
- [ ] GoogleService-Info.plist is for production project
- [ ] App has notification permission granted
- [ ] Device is not in Do Not Disturb mode
- [ ] App is not in foreground (foreground notifications require handler)

**Debug Steps:**
1. Check Firebase Console → Cloud Messaging → Send test message
2. Review Functions logs: `firebase functions:log`
3. Check device logs in Xcode → **Window** → **Devices and Simulators**

### Issue: "Registration succeeded, but failed to subscribe to topic"

**Cause:** Topic subscription failed after token registration.

**Solution:**
```dart
// Manually subscribe
await FirebaseMessaging.instance.subscribeToTopic('metro_slc_daily');
```

Check logs for errors:
```
⚠️ Failed to subscribe to metro_slc_daily: <error>
```

### Issue: Daily digest not sent

**Checklist:**
- [ ] `scheduleDailyDigest` function deployed
- [ ] Cloud Scheduler job created and enabled
- [ ] Articles exist for the metro (check Firestore)
- [ ] Users subscribed to topic (check Firestore `users/{uid}/notification_opt_in`)

**Verify Scheduler Job:**
```bash
gcloud scheduler jobs list --project=brightside-9a2c5
```

**Manually Trigger:**
```bash
gcloud scheduler jobs run daily-digest-slc --project=brightside-9a2c5
```

### Issue: APNs certificate vs Auth Key

**BrightSide uses Auth Key (recommended)**, not certificates.

**Why Auth Key?**
- ✅ Never expires (unlike certificates which expire yearly)
- ✅ Works for all apps under your Team ID
- ✅ Easier to manage

**If you see "APNs Certificate" in old docs, ignore it.** Use Auth Key as documented above.

---

## Production Checklist

Before releasing to App Store:

- [ ] APNs Auth Key uploaded to Firebase Console
- [ ] Bundle ID verified in Apple Developer, Xcode, and Firebase
- [ ] Push Notifications capability enabled in Xcode
- [ ] Background Modes → Remote notifications enabled
- [ ] GoogleService-Info.plist for **production** Firebase project
- [ ] TestFlight build receives test notifications
- [ ] TestFlight build receives daily digest at 7 AM
- [ ] Notification permission soft-asked after first feed load
- [ ] Device tokens stored in Firestore `/users/{uid}/devices/{deviceId}`
- [ ] Topic subscription working for `metro_{id}_daily`
- [ ] Functions deployed: `scheduleDailyDigest`, `sendTestPush`

---

## Security & Privacy

### Apple App Store Review

**App Store requires notification permission explanation:**

In `ios/Runner/Info.plist`, add:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>BrightSide sends you a daily digest of positive news from your local community. You can customize or disable notifications in Settings.</string>
```

### User Control

Users can control notifications:
1. **In-app Settings:** Enable/disable digest, change metro
2. **iOS Settings:** Disable notifications entirely for BrightSide
3. **Account deletion:** Automatically unsubscribes from all topics

### Notification Content

Daily digest includes:
- **Title:** "Your Daily BrightSide ☀️"
- **Body:** "8 positive stories from [Metro] today"
- **Data:** `{ type: 'daily_digest', metro_id: 'slc' }`

No personal data is sent in notifications.

---

## Monitoring

### Firebase Cloud Messaging Dashboard

View delivery stats:
1. Firebase Console → **Cloud Messaging**
2. View **Impressions** (delivered)
3. View **Opens** (notification tapped)

### Functions Logs

```bash
# Real-time logs
firebase use prod
firebase functions:log --only scheduleDailyDigest

# Filter by metro
firebase functions:log --only scheduleDailyDigest | grep SLC
```

### Analytics

Track notification events:
```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'notification_received',
  parameters: {'type': 'daily_digest', 'metro': 'slc'},
);
```

---

## Additional Resources

- [Apple Push Notification Service](https://developer.apple.com/documentation/usernotifications)
- [Firebase Cloud Messaging iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Flutter firebase_messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [TestFlight Documentation](https://developer.apple.com/testflight/)

---

## Quick Commands Reference

```bash
# Build iOS production
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true --release

# Archive in Xcode
open ios/Runner.xcworkspace
# Product → Archive

# Deploy Functions
cd functions && npm run deploy:prod

# Test notification (Functions shell)
npm run shell
> sendTestPush({ uid: 'user-uid-here' })

# View logs
firebase functions:log --only scheduleDailyDigest
firebase functions:log --only sendTestPush

# Trigger daily digest manually
gcloud scheduler jobs run daily-digest-slc --project=brightside-9a2c5
```
