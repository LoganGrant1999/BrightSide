# Release Build Checklist

Checklist for ensuring BrightSide is ready for production release.

---

## Debug UI & Features

### ✅ Debug Menu Guards
**Location:** `lib/features/settings/settings_screen.dart:183`

All debug features are guarded with `!Env.isProd && !kReleaseMode`:
- Admin portal link
- Fix seed for metro
- Health indicators
- Send test notification

**Test:**
```bash
# Build release and verify no debug menu appears
flutter build ios --release -t lib/main_prod.dart
```

### ✅ Crash Trigger Guard
**Location:** `lib/features/settings/settings_screen.dart:647`

Test crash feature (7-tap version) is guarded with `kReleaseMode || Env.isProd` early return.

**Test:**
- Tap version 7 times in release build → no crash dialog should appear

---

## Logging

### ✅ HTTP Logging
**Location:** `lib/features/story/data/http_story_repository.dart:46`

Dio `LogInterceptor` only enabled in debug mode:
```dart
if (!kReleaseMode) {
  _dio.interceptors.add(LogInterceptor(...));
}
```

### ✅ Analytics Logging
**Location:** `lib/core/services/analytics.dart`

All analytics events use `debugPrint()` which is automatically stripped in release mode:
```dart
if (kDebugMode) {
  debugPrint('[Analytics] app_open');
}
```

### ✅ Other Logging
All other logging uses `debugPrint()`:
- `notification_service.dart` - FCM token, permission status
- `system_config.dart` - Config load warnings
- `firebase_boot.dart` - Emulator connection, Crashlytics status
- `issue_cache.dart` - Cache operations

**Note:** `debugPrint()` is automatically a no-op in release mode (Flutter framework behavior).

---

## Analytics Events

### ✅ Production Events (Always Logged)

**Core user actions only:**

1. **app_open** - `lib/main_prod.dart:33`, `lib/main_dev.dart:31`, `lib/main.dart:22`
   - Fired on app launch
   - No parameters

2. **metro_set** - `lib/features/metro/metro_provider.dart:114`
   - Fired when user selects/changes metro
   - Parameters: `metro_id`

3. **article_open** - `lib/shared/widgets/story_card.dart:190`
   - Fired when user opens article
   - Parameters: `article_id`, `metro_id`

4. **notif_open** - `lib/features/notifications/services/notification_service.dart:181`
   - Fired when user taps notification
   - Parameters: `metro_id`, `article_id` (optional)

### ❌ No Excessive/Debug Events

**Verified:** No analytics events for:
- UI interactions (scroll, swipe, etc.)
- Cache operations
- Background tasks
- Debug actions

---

## Release Build Commands

### iOS Release
```bash
# Production release
flutter build ios --release -t lib/main_prod.dart

# Verify no debug symbols
nm -a build/ios/Release-iphoneos/Runner.app/Runner | grep -i debug
# Should return no results
```

### Build Info
```bash
# Check version
grep 'version:' pubspec.yaml
# Should show: version: 1.0.0+1
```

---

## Manual Testing

### Settings Screen
- [ ] No "Developer" section appears
- [ ] Tapping version 7 times does nothing (no crash dialog)
- [ ] Only shows: Account, Notifications, Location, Legal, About

### App Behavior
- [ ] No console logs in Xcode release build
- [ ] No HTTP request/response logging
- [ ] No analytics debug prints
- [ ] App launches cleanly without debug warnings

### Analytics (Firebase Console)
- [ ] Verify only 4 events appear: `app_open`, `metro_set`, `article_open`, `notif_open`
- [ ] No excessive events or debug events

---

## Code Review

### Files to Check
- ✅ `lib/features/settings/settings_screen.dart` - Debug guards
- ✅ `lib/features/story/data/http_story_repository.dart` - HTTP logging guard
- ✅ `lib/core/services/analytics.dart` - Event list
- ✅ All files using `debugPrint()` (auto-stripped in release)

### Anti-Patterns to Avoid
- ❌ `print()` statements (use `debugPrint()` instead)
- ❌ Debug UI without `kReleaseMode` or `Env.isProd` guards
- ❌ Analytics events for every user action
- ❌ Verbose logging in production

---

## Firebase Analytics Configuration

**Review Firebase Console:**
1. Go to Analytics → Events
2. Verify only 4 custom events:
   - `app_open`
   - `metro_set`
   - `article_open`
   - `notif_open`
3. Standard Firebase events (e.g., `session_start`, `first_open`) are expected

**User Properties:**
- `metro` - User's selected metro (set via `AnalyticsService.setUserMetro()`)
- `user_id` - Firebase Auth UID (set on sign-in)

---

## App Store Submission

**Before submitting to App Store:**
- [ ] Run release build checklist
- [ ] Verify no debug UI visible
- [ ] Check Firebase Analytics dashboard for event sanity
- [ ] Test on physical device (not simulator)
- [ ] Verify Crashlytics is enabled (`Env.isProd` → enabled)
- [ ] Ensure version number matches App Store submission

---

## Continuous Monitoring

**Post-Release:**
1. Monitor Firebase Analytics for event volume
2. Check Crashlytics for crash reports
3. Review user feedback for unexpected behavior
4. Verify analytics data quality (no spam events)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-06 | Initial release checklist |

---

**For questions:** support@brightside.com
