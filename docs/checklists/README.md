# QA Checklists

Quick reference for testing and verification before deployment.

---

## Available Checklists

### 1. [Preflight Checklist](./preflight.md)
**Purpose:** Comprehensive QA verification before App Store submission  
**Time Required:** 4-6 hours  
**Use When:** Before submitting to App Store or deploying to production

**Covers:**
- Onboarding flow (metro selection, location permissions)
- Authentication (Google, Apple, Email/Password)
- Today feed (5 stories, 5 AM cutoff)
- Popular feed
- Submit flow + admin approval
- Likes & featured stories
- Offline caching & error handling
- Notifications (soft-ask, 7 AM digest)
- Account deletion cascade
- Legal links & permission strings
- Performance & polish
- Cross-device testing
- Security & privacy
- App Store compliance

---

## Environment Check Tool

**Location:** `tool/print_env_check.ts`

**Usage:**
```bash
# Development/Emulator mode
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts

# Production mode
npx ts-node tool/print_env_check.ts
```

**What it checks:**
- Environment (dev vs prod)
- Firebase project ID
- System configuration (legal URLs, maintenance mode, max articles)
- Health check timestamps (last ingest/digest per metro)
- Content status (stories available per metro)
- URL accessibility (production only)

**Expected output (dev):**
```
═══════════════════════════════════════════════════════════
  BrightSide Environment Check
═══════════════════════════════════════════════════════════

📦 ENVIRONMENT
   Environment: DEVELOPMENT
   isProd: false
   isDev: true
   Emulator Host: 127.0.0.1:8080

🔥 FIREBASE CONFIGURATION
   Project ID: brightside-9a2c5
   Using Emulators: ✓

⚙️  SYSTEM CONFIGURATION
   Privacy Policy URL: https://brightside-9a2c5.web.app/legal/privacy
   Terms of Service URL: https://brightside-9a2c5.web.app/legal/terms
   Support Email: support@brightside.com
   Maintenance Mode: ✓ Disabled
   Max Articles (Today): 8

🏥 SYSTEM HEALTH
   Metro: SLC
     Last Ingest: 2025-01-06 08:15 ✓
       (2h 30m ago)
     Last Digest: 2025-01-06 07:00 ✓
       (3h 45m ago)
   ...

📰 CONTENT STATUS
   SLC: 25 published stories ✓
   NYC: 18 published stories ✓
   GSP: 12 published stories ✓

⚠️  WARNINGS & RECOMMENDATIONS
   ⚠️  Running in DEVELOPMENT mode
   • Using Firebase emulators
   • Debug features enabled
   • For production, unset FIRESTORE_EMULATOR_HOST

═══════════════════════════════════════════════════════════
  Environment check complete
═══════════════════════════════════════════════════════════
```

---

## Quick Pre-Ship Checklist

**5-minute sanity check before deploying:**

### Environment
- [ ] Run `npx ts-node tool/print_env_check.ts`
- [ ] Verify production mode (isProd: true)
- [ ] Legal URLs accessible
- [ ] Health checks recent (<24h)
- [ ] Stories available for all metros

### Code
- [ ] Run `flutter analyze` → no errors
- [ ] Version number incremented in pubspec.yaml
- [ ] Build number incremented

### Build
- [ ] Build release: `flutter build ios --release -t lib/main_prod.dart`
- [ ] No debug menu in Settings
- [ ] Test on physical device (not simulator)

### Firebase
- [ ] APNs key configured (iOS push notifications)
- [ ] Crashlytics enabled
- [ ] Security rules deployed
- [ ] System config seeded

### Legal
- [ ] Privacy Policy URL works
- [ ] Terms of Service URL works
- [ ] Both legal docs are up-to-date

### Notifications
- [ ] Test notification appears on physical device
- [ ] Notification tap opens app correctly

---

## Issue Severity Levels

**P0 - Critical (Must Fix Before Ship):**
- Crashes
- Data loss
- Security vulnerabilities
- Core features broken (auth, feed, submit)

**P1 - High (Should Fix Before Ship):**
- Major bugs affecting primary user flows
- Poor error handling
- Broken links or images

**P2 - Medium (Fix If Time):**
- Minor bugs
- UX improvements
- Edge cases

**P3 - Low (Defer to Next Release):**
- Polish
- Nice-to-haves
- Non-critical edge cases

---

## Testing Tips

### Test Accounts
Create test accounts for each auth provider:
- Google: testuser@gmail.com
- Apple: Use Sign in with Apple test account
- Email: test@brightside.com / TestPassword123!

### Test Devices
Minimum recommended:
- iPhone SE (small screen)
- iPhone 15 Pro Max (large screen)
- iOS 14 (minimum supported version)
- iOS 17 (latest)

### Test Data
- Have at least 8 published stories per metro for Today feed testing
- Have featured stories for testing like restrictions
- Have pending submissions for admin portal testing

### Common Issues
- **Emulator vs Physical Device:** Some features (notifications, location) require physical device
- **Cache Issues:** Clear app data between test runs
- **Network Issues:** Test both online and offline scenarios

---

## Related Documentation

- [Release Checklist](../RELEASE_CHECKLIST.md) - Release build verification
- [App Store Metadata](../app-store/metadata.md) - App Store submission details
- [Screenshots Guide](../app-store/screenshots.md) - Screenshot requirements
- [Legal Deployment](../legal/DEPLOYMENT.md) - Legal docs deployment
- [APNs Setup](../push/APNS_SETUP.md) - iOS push notifications

---

**Last Updated:** 2025-01-06  
**Version:** 1.0.0  
**Questions?** support@brightside.com

---

## Quick Command Reference

### Environment Check
```bash
# Production
npx ts-node tool/print_env_check.ts

# Development
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts
```

### Build Commands
```bash
# Analyze code
flutter analyze

# Build release (iOS)
flutter build ios --release -t lib/main_prod.dart

# Run in development
flutter run -t lib/main_dev.dart
```

### Firebase Commands
```bash
# Seed system config
npx ts-node tool/seed_system_config.ts

# Deploy legal site
firebase deploy --only hosting:legal

# Deploy security rules
firebase deploy --only firestore:rules
```

### Quick Verification
```bash
# 1. Check environment
npx ts-node tool/print_env_check.ts

# 2. Analyze code
flutter analyze

# 3. Build release
flutter build ios --release -t lib/main_prod.dart

# 4. Verify version
grep 'version:' pubspec.yaml
```

---

**Pro Tip:** Bookmark `PREFLIGHT_SUMMARY.md` in the project root for fastest access to critical checks.
