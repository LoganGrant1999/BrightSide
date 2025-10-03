# iOS Push Notifications Setup Guide

This guide walks you through setting up FCM push notifications for BrightSide on iOS.

## Prerequisites

- Active Apple Developer account
- Xcode project configured with correct bundle identifier
- Firebase project with iOS app registered
- Physical iOS device (push notifications don't work on simulator)

## Part 1: Apple Developer Console Setup

### 1. Generate APNs Authentication Key

1. Go to [Apple Developer Console](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Keys** from the sidebar
4. Click the **+** button to create a new key
5. Enter a name like "BrightSide Push Notifications"
6. Check **Apple Push Notifications service (APNs)**
7. Click **Continue** and then **Register**
8. **Download the .p8 file** and save it securely
9. **Copy the Key ID** (shown after registration)
10. **Copy your Team ID** (found in top-right of developer console)

⚠️ **Important**: You can only download the .p8 file once. Store it securely.

### 2. Configure App ID

1. In **Certificates, Identifiers & Profiles**, select **Identifiers**
2. Find your app's identifier (e.g., `com.brightside.app`)
3. Ensure **Push Notifications** capability is checked
4. Click **Save** if you made changes

## Part 2: Firebase Console Setup

### 1. Upload APNs Key to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your BrightSide project
3. Click the gear icon → **Project settings**
4. Go to the **Cloud Messaging** tab
5. Scroll to **Apple app configuration**
6. Under **APNs authentication key**, click **Upload**
7. Upload your .p8 file
8. Enter your **Key ID** and **Team ID**
9. Click **Upload**

### 2. Verify iOS App Configuration

1. Still in **Project settings**, go to **General** tab
2. Scroll to **Your apps** section
3. Find your iOS app
4. Verify the **Bundle ID** matches your Xcode project
5. Download **GoogleService-Info.plist** if you haven't already

## Part 3: Xcode Project Configuration

### 1. Add Push Notifications Capability

1. Open your project in Xcode
2. Select your target (BrightSide)
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Push Notifications**
6. Add **Background Modes** (if not already added)
7. Under Background Modes, check:
   - ✅ Remote notifications
   - ✅ Background fetch (optional)

### 2. Update Info.plist

Ensure your `ios/Runner/Info.plist` includes:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### 3. Update AppDelegate.swift

Your `ios/Runner/AppDelegate.swift` should already be configured from Firebase setup, but verify it includes:

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // Request notification authorization
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 4. Verify GoogleService-Info.plist

1. Ensure `GoogleService-Info.plist` is in `ios/Runner/`
2. In Xcode, verify it's added to the Runner target
3. Build Settings → ensure file is included in "Copy Bundle Resources"

## Part 4: Testing Notifications

### 1. Build and Run on Physical Device

```bash
# Clean build
flutter clean
flutter pub get

# Run on physical device (select your device in Xcode or use)
flutter run --release
```

⚠️ **Important**: Must test on a physical device, not simulator.

### 2. Grant Notification Permission

1. Open BrightSide app on device
2. Complete onboarding flow
3. Sign in with an account
4. Go to **Settings → Push Notifications**
5. Tap **Enable Notifications**
6. Grant permission when iOS prompts
7. Toggle **Daily Digest** ON
8. Verify you see "You'll receive notifications at 7:00 AM"

### 3. Verify FCM Token Registration

Check Firestore console at:
```
/users/{userId}/devices/{deviceId}
```

Should contain:
- `fcm_token`: FCM registration token
- `apns_token`: APNs device token (hex string)
- `platform`: "ios"
- `app_version`: App version
- `last_seen`: Recent timestamp

### 4. Test with Manual Trigger

You can test notifications immediately using the test Cloud Function:

```bash
# Using curl
curl -X POST https://us-central1-brightside-9a2c5.cloudfunctions.net/sendTestDigest \
  -H "Content-Type: application/json" \
  -d '{"metroId": "slc"}'

# Or using Firebase console
# Go to Functions → sendTestDigest → Testing tab
# Input: {"metroId": "slc"}
```

If configured correctly, you should receive a notification on your device.

## Part 5: Deploy Cloud Functions

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. Deploy Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

This deploys:
- `slcDailyDigest` - Sends at 7 AM Mountain Time
- `nycDailyDigest` - Sends at 7 AM Eastern Time
- `gspDailyDigest` - Sends at 7 AM Eastern Time
- `sendTestDigest` - HTTP endpoint for testing

### 3. Verify Deployment

1. Go to [Firebase Console → Functions](https://console.firebase.google.com)
2. Verify all 4 functions are listed
3. Check function logs for any errors
4. Note the URLs for HTTP functions

## Part 6: Production Testing

### 1. Wait for Scheduled Digest

The daily digest will automatically send at 7:00 AM local time for each metro:
- **SLC**: 7:00 AM Mountain Time (America/Denver)
- **NYC**: 7:00 AM Eastern Time (America/New_York)
- **GSP**: 7:00 AM Eastern Time (America/New_York)

### 2. Monitor Function Logs

```bash
# Stream logs
firebase functions:log

# Or view in console
# Firebase Console → Functions → Select function → Logs tab
```

Look for:
```
Sending daily digest for metro: slc
Daily digest sent to metro_slc_daily. Message ID: [id]
```

### 3. Verify Analytics

Check Firestore collection `/analytics` for events:
```javascript
{
  event: "daily_digest_sent",
  metro_id: "slc",
  article_count: 5,
  timestamp: [serverTimestamp]
}
```

## Troubleshooting

### No notifications received

1. **Check notification permission**:
   - iOS Settings → BrightSide → Notifications → Ensure "Allow Notifications" is ON

2. **Verify topic subscription**:
   - Check Cloud Functions logs for subscription confirmation
   - Ensure user's metro matches the topic (`metro_slc_daily`, etc.)

3. **Check APNs token**:
   - In Firestore, verify `users/{uid}/devices/{device}` has `apns_token`
   - If null, the device hasn't successfully registered with APNs

4. **Validate APNs key in Firebase**:
   - Firebase Console → Project Settings → Cloud Messaging
   - Ensure APNs authentication key is uploaded and valid

5. **Check function errors**:
   ```bash
   firebase functions:log --only slcDailyDigest
   ```

### Notifications work in test but not scheduled

1. **Verify function is deployed**:
   ```bash
   firebase functions:list
   ```

2. **Check function schedule**:
   - Functions must be deployed to execute on schedule
   - Test functions don't trigger scheduled execution

3. **Timezone verification**:
   - Scheduled functions use specific timezones
   - Verify your metro's timezone in `functions/src/notifications.ts`

### APNs token is null

1. **Check iOS entitlements**:
   - Ensure Push Notifications capability is enabled in Xcode
   - Verify provisioning profile includes push notifications

2. **Device limitations**:
   - Push notifications don't work on iOS Simulator
   - Must use physical device

3. **Firebase configuration**:
   - Ensure `GoogleService-Info.plist` is correctly placed
   - Rebuild app after adding Firebase configuration

## Deep Linking (Optional)

To handle notification taps and navigate to specific screens:

### Update AppDelegate.swift

```swift
override func application(
  _ application: UIApplication,
  didReceiveRemoteNotification userInfo: [AnyHashable: Any],
  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
  // Handle notification tap
  if let route = userInfo["route"] as? String {
    // Navigate to route (e.g., "/today")
  }
  completionHandler(.newData)
}
```

The Cloud Functions already include deep link data:
```typescript
data: {
  route: "/today"
}
```

## Security Notes

1. **APNs Key**: Store your .p8 file securely. Do not commit to git.
2. **Service Account**: Keep `serviceAccountKey.json` out of version control (already in .gitignore)
3. **Test Functions**: Consider adding authentication to `sendTestDigest` in production
4. **Rate Limiting**: Firebase automatically handles rate limiting for scheduled functions

## Next Steps

1. ✅ Complete iOS setup and deploy functions
2. Monitor notification delivery rates in Firebase Console
3. Implement notification analytics in the app
4. Add notification preferences (time, frequency, etc.)
5. Implement in-app notification handling (show banner while app is open)
6. Add notification action buttons (e.g., "Read", "Dismiss")

## Resources

- [Firebase Cloud Messaging for iOS](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs Documentation](https://developer.apple.com/documentation/usernotifications)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Cloud Functions Scheduled Triggers](https://firebase.google.com/docs/functions/schedule-functions)
