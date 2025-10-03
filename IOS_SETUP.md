# iOS Setup Instructions for BrightSide Authentication

This guide walks you through configuring Firebase Authentication with Google Sign-In and Sign in with Apple for iOS.

## Prerequisites

- Firebase project created and configured (`brightside-9a2c5`)
- Xcode installed
- Physical iOS device or simulator (iOS 14+)

## 1. Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/project/brightside-9a2c5/settings/general/)
2. Navigate to **Project Settings** > **General**
3. Scroll down to **Your apps** section
4. Click on the iOS app (if not created, click "Add app" and follow instructions)
5. Download `GoogleService-Info.plist`
6. Add it to your Xcode project:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
7. In Xcode: Right-click `Runner` folder → **Add Files to "Runner"** → Select `GoogleService-Info.plist`
8. Make sure **"Copy items if needed"** is checked
9. Make sure **"Runner" target** is selected

## 2. Configure Google Sign-In

### 2.1 Get Reversed Client ID

Open `GoogleService-Info.plist` and find the `REVERSED_CLIENT_ID` value. It should look like:
```
com.googleusercontent.apps.123456789-abcdefg
```

### 2.2 Add URL Scheme in Xcode

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **Runner** project in the navigator
3. Select **Runner** target
4. Go to **Info** tab
5. Expand **URL Types** section
6. Click **+** to add a new URL Type
7. Fill in:
   - **Identifier**: `com.googleusercontent.apps` (or any unique identifier)
   - **URL Schemes**: Paste your `REVERSED_CLIENT_ID` from step 2.1
   - **Role**: Editor

![URL Types Screenshot](https://firebase.google.com/docs/auth/images/ios-url-scheme.png)

## 3. Configure Sign in with Apple

### 3.1 Enable Apple Sign In Capability

1. In Xcode, select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Search for and add **"Sign in with Apple"**

### 3.2 Enable in Firebase Console

1. Go to [Firebase Console Authentication](https://console.firebase.google.com/project/brightside-9a2c5/authentication/providers)
2. Click **Sign-in method** tab
3. Enable **Apple** provider
4. Add your Apple Developer Team ID (found in Apple Developer account)
5. Click **Save**

### 3.3 Configure App ID in Apple Developer

1. Go to [Apple Developer Console](https://developer.apple.com/account/resources/identifiers/list)
2. Select your App ID (or create one matching your bundle identifier)
3. Enable **"Sign in with Apple"** capability
4. Click **Save**

## 4. Update Info.plist (if needed)

If you encounter issues with Google Sign-In, you may need to add a URL scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
    </array>
  </dict>
</array>
```

## 5. Set Minimum iOS Version

Ensure your app targets iOS 14.0 or later:

1. Open `ios/Podfile`
2. Update the platform line:
   ```ruby
   platform :ios, '14.0'
   ```
3. Run `cd ios && pod install`

## 6. Test Authentication

### 6.1 Run the App

```bash
flutter run
```

### 6.2 Test Each Provider

1. **Apple Sign In**: Click "Continue with Apple"
   - Should show Apple's native authentication sheet
   - First time: asks for email/name permission
   - Creates user doc in Firestore `/users/{uid}`

2. **Google Sign In**: Click "Continue with Google"
   - Should show Google account picker
   - Creates user doc in Firestore `/users/{uid}`

3. **Email/Password**: Click "Continue with Email"
   - Test sign up (creates account)
   - Test sign in (existing account)
   - Test password reset (sends email)

### 6.3 Verify Firestore

Check [Firestore Console](https://console.firebase.google.com/project/brightside-9a2c5/firestore/data/~2Fusers~2F) to confirm user docs are created with:
- `email`
- `auth_provider` (google/apple/email)
- `display_name`
- `chosen_metro` (if selected during onboarding)
- `notification_opt_in` (false)
- `created_at`
- `updated_at`

## 7. Troubleshooting

### Google Sign-In Not Working

- Verify `REVERSED_CLIENT_ID` is correctly added to URL Schemes
- Check `GoogleService-Info.plist` is in the project
- Ensure OAuth client is configured in Google Cloud Console

### Apple Sign In Not Working

- Verify "Sign in with Apple" capability is added
- Check Apple Developer App ID has capability enabled
- Ensure device/simulator is iOS 13+
- Verify Apple provider is enabled in Firebase Console

### Account Linking Issues

If you see "account-exists-with-different-credential" error:
- This is expected behavior for security
- User must sign in with original provider first
- Linking will be available in Settings (future feature)

## 8. Production Checklist

Before releasing to App Store:

- [ ] `GoogleService-Info.plist` is added and not tracked in git
- [ ] Reversed Client ID is correctly configured
- [ ] Sign in with Apple capability is enabled
- [ ] Apple Developer App ID has Sign in with Apple enabled
- [ ] Firebase Authentication providers are enabled (Google, Apple, Email/Password)
- [ ] Privacy Policy and Terms of Service links are added to auth screens
- [ ] Test all sign-in flows on physical device

## Next Steps

Once authentication is working:
- Wire Settings → Account page to show user info
- Test session persistence (relaunch app should stay signed in)
- Test metro backfill (local metro → Firestore on first sign-in)
