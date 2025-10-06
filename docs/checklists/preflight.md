# BrightSide Preflight Checklist

Comprehensive QA verification before App Store submission or production deployment.

---

## Environment Verification

**Before testing, run:**
```bash
# Check environment configuration (dev/emulator mode)
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/print_env_check.ts

# OR check production environment
npx ts-node tool/print_env_check.ts
```

**Verify output shows:**
- ✅ Correct environment (DEVELOPMENT or PRODUCTION)
- ✅ Correct Firebase project ID (brightside-9a2c5)
- ✅ Legal URLs are accessible (production only)
- ✅ Health check timestamps are recent (<24h)
- ✅ Stories available for all metros (SLC, NYC, GSP)

---

## 1. Onboarding Flow

### Metro Selection
- [ ] **Launch app for first time** (fresh install)
- [ ] Location permission dialog appears
- [ ] **Allow location** → app detects correct metro based on GPS
- [ ] Verify correct metro selected (SLC, NYC, or GSP)
- [ ] **Deny location** → manual metro picker appears
- [ ] Select metro manually → proceeds to Today feed

### Edge Cases
- [ ] **Outside supported metros** → defaults to SLC (or shows "not available" message)
- [ ] **Airplane mode** → manual picker appears, no crash
- [ ] Change metro in Settings → Today feed updates immediately

**Expected Behavior:**
- Clean, friendly UX with no errors
- Location permission requested politely (not intrusive)
- Manual fallback always available

---

## 2. Authentication

### Google Sign-In
- [ ] Tap "Sign in with Google" on auth screen
- [ ] Google account picker appears
- [ ] Select account → signs in successfully
- [ ] User name/email displayed in Settings
- [ ] Sign out → returns to guest mode

### Apple Sign-In
- [ ] Tap "Sign in with Apple" on auth screen
- [ ] Apple Face ID / Touch ID prompt appears
- [ ] Authenticate → signs in successfully
- [ ] User name displayed in Settings (or email if name hidden)
- [ ] Sign out → returns to guest mode

### Email/Password Sign-In
- [ ] Tap "Sign in with Email"
- [ ] Enter valid email + password → signs in
- [ ] Enter invalid credentials → shows friendly error
- [ ] "Forgot password?" link works (if implemented)
- [ ] Sign out → returns to guest mode

### Account Linking
- [ ] Sign in with Google
- [ ] Sign out
- [ ] Sign in with Apple using **same email**
- [ ] Verify account is linked (same user data)
- [ ] Settings shows both providers linked

### Edge Cases
- [ ] **No internet** → friendly error message
- [ ] **Cancel Google picker** → returns to auth screen, no crash
- [ ] **Cancel Apple auth** → returns to auth screen, no crash
- [ ] Sign in → close app → reopen → still signed in

**Expected Behavior:**
- All auth methods work seamlessly
- Account linking works for same email
- Graceful error handling
- Session persists across app restarts

---

## 3. Today Feed

### Standard Load (8 Stories)
- [ ] Open Today tab
- [ ] **5 stories** appear (or fewer if not enough curated)
- [ ] Stories have: image, headline, source, publish date
- [ ] All images load correctly (no broken images)
- [ ] Scroll works smoothly

### 5 AM Window Test
**Test Time:** Before 5 AM local time
- [ ] Today feed shows **previous day's** stories
- [ ] "New stories available at 5 AM" message appears (if implemented)

**Test Time:** After 5 AM local time
- [ ] Today feed shows **fresh stories** for today
- [ ] Story count resets to ≤5

### Story Interaction
- [ ] Tap story card → opens story detail
- [ ] Story detail shows: full image, headline, body, source link
- [ ] "Read Full Article" button opens external browser
- [ ] Back button returns to Today feed
- [ ] Like story → like count increments
- [ ] Unlike story → like count decrements

### Featured Stories
- [ ] Featured story (if any) shows "Featured" badge
- [ ] Featured story **cannot be liked** (like button disabled/hidden)
- [ ] Regular stories can be liked

### Edge Cases
- [ ] **No stories available** → friendly "No stories yet" message
- [ ] **No internet** → cached stories appear (if previously loaded)
- [ ] **Pull to refresh** → reloads stories
- [ ] Switch metro → Today feed updates for new metro

**Expected Behavior:**
- Clean, fast feed load
- 5 AM cutoff works correctly
- Featured stories handled properly
- Offline caching works

---

## 4. Popular Feed

### Standard Load
- [ ] Open Popular tab
- [ ] Stories appear sorted by likes/engagement
- [ ] Stories show like count
- [ ] Mix of recent and older popular stories

### Story Interaction
- [ ] Tap story → opens story detail
- [ ] Like story → like count increments
- [ ] Unlike story → like count decrements
- [ ] Story appears in both Today and Popular (if recently published)

### Edge Cases
- [ ] **No popular stories** → friendly "No popular stories yet" message
- [ ] **Pull to refresh** → reloads popular stories
- [ ] Switch metro → Popular feed updates for new metro

**Expected Behavior:**
- Popular stories reflect community engagement
- Like counts are accurate
- No duplicate stories (unless also in Today)

---

## 5. Submit Flow

### Story Submission
- [ ] Open Submit tab
- [ ] Enter story URL (e.g., news article link)
- [ ] URL validation works (reject invalid URLs)
- [ ] Enter optional note/context
- [ ] Tap "Submit for Review" → success message
- [ ] Submission appears in admin portal (pending status)

### Admin Approval
**Admin Portal:**
- [ ] Sign in to admin portal (https://brightside-9a2c5.web.app/admin)
- [ ] Pending submissions appear in moderation queue
- [ ] Review submission → approve
- [ ] Approved story appears in Today feed (for correct metro)

**Admin Portal (Rejection):**
- [ ] Review submission → reject with reason
- [ ] User receives rejection notification (if implemented)

### Edge Cases
- [ ] **Submit duplicate URL** → shows "already submitted" message
- [ ] **Submit invalid URL** → validation error
- [ ] **Submit with no internet** → friendly error, submission saved locally (if implemented)
- [ ] **Submit spam/inappropriate content** → admin can reject

**Expected Behavior:**
- Submit flow is simple and fast
- Admin moderation works correctly
- Approved stories appear in feed within minutes

---

## 6. Likes & Featured Stories

### Like Functionality
- [ ] Like a story → like count +1
- [ ] Unlike a story → like count -1
- [ ] Like persists across app restarts
- [ ] Like syncs across devices (if signed in)

### Featured Stories
- [ ] Featured story shows "Featured" badge (or distinct styling)
- [ ] Featured story **does not show like button**
- [ ] Featured story cannot be liked (UI prevents interaction)
- [ ] Regular stories show like button normally

### Edge Cases
- [ ] **Like while offline** → like queued, syncs when online
- [ ] **Unlike while offline** → unlike queued, syncs when online
- [ ] **Multiple rapid likes** → debounced, final state is correct

**Expected Behavior:**
- Likes are fast and reliable
- Featured stories handled correctly
- Offline support works

---

## 7. Offline Caching & Error Handling

### Offline Caching
- [ ] Load Today feed with internet → stories cached
- [ ] Turn off internet (airplane mode)
- [ ] Reopen app → cached stories appear
- [ ] "Offline mode" indicator shown (optional)
- [ ] Turn on internet → fresh stories load

### Error Handling
- [ ] **No internet on first launch** → friendly "No connection" message
- [ ] **Server error (5xx)** → retry automatically (or show retry button)
- [ ] **Story not found (404)** → friendly "Story not available" message
- [ ] **Timeout** → friendly "Request timed out" message

### Edge Cases
- [ ] **Network drops mid-load** → partial data handled gracefully
- [ ] **Stale cache (>24h old)** → shows cached + "outdated" indicator
- [ ] **Clear cache** → Settings → Delete Local Data → cache cleared

**Expected Behavior:**
- Offline experience is usable
- All errors have friendly messages
- No crashes on network issues

---

## 8. Notifications

### Permission Flow
- [ ] First launch → no permission prompt (soft-ask)
- [ ] View first Today feed → after 2 seconds, permission prompt appears
- [ ] **Allow notifications** → FCM token saved
- [ ] **Deny notifications** → graceful fallback, no re-prompt

### Settings Toggle
- [ ] Settings → Notifications → toggle notifications ON
- [ ] Verify FCM token saved to Firestore `/users/{uid}/devices/{deviceId}`
- [ ] Verify subscribed to topic: `metro_{metroId}_daily`
- [ ] Settings → Notifications → toggle notifications OFF
- [ ] Verify unsubscribed from topic

### 7 AM Daily Digest
**Production Test:**
- [ ] Enable notifications
- [ ] Wait until 7 AM local time next morning
- [ ] Receive daily digest notification
- [ ] Tap notification → opens Today feed with fresh stories

**Dev Test (Test Button):**
- [ ] Settings → Developer → "Send test notification"
- [ ] Notification appears on device
- [ ] Tap notification → opens app

### Edge Cases
- [ ] **Notifications disabled in iOS Settings** → in-app toggle reflects this
- [ ] **Multiple devices** → all devices receive digest
- [ ] **Change metro** → unsubscribe from old topic, subscribe to new topic

**Expected Behavior:**
- Soft-ask permission pattern works
- 7 AM digest arrives reliably
- Notification taps open app correctly

---

## 9. Account Deletion

### Delete Account Flow
- [ ] Sign in
- [ ] Settings → Account → "Delete Account"
- [ ] Confirmation dialog appears with warning
- [ ] Tap "Delete Forever" → account deletion starts
- [ ] Loading indicator shown
- [ ] Success message: "Account deleted successfully"
- [ ] Signed out and returned to Today feed (guest mode)

### Data Cascade Verification
**Firebase Console:**
- [ ] `/users/{uid}` document deleted
- [ ] `/users/{uid}/devices/*` subcollection deleted
- [ ] All submissions by user marked as `deleted_user` (or removed)
- [ ] All likes by user removed from stories
- [ ] FCM tokens removed
- [ ] Auth account deleted

### Edge Cases
- [ ] **Cancel deletion** → returns to Settings, no changes
- [ ] **No internet during deletion** → friendly error, retry later
- [ ] **Partial deletion failure** → Cloud Function handles cleanup

**Expected Behavior:**
- Account deletion is permanent and complete
- All user data is removed
- No orphaned data in Firestore

---

## 10. Legal Links & Permissions

### Legal Links
- [ ] Settings → Privacy Policy → opens in external browser
- [ ] Privacy Policy URL loads: https://brightside-9a2c5.web.app/legal/privacy
- [ ] Settings → Terms of Service → opens in external browser
- [ ] Terms of Service URL loads: https://brightside-9a2c5.web.app/legal/terms
- [ ] Both legal pages are readable and properly formatted

### Permission Strings (iOS)
**Test on physical device:**
- [ ] Location permission dialog shows custom message (check Info.plist)
  - Expected: "BrightSide uses your location to show relevant local news stories."
- [ ] Notification permission dialog shows custom message
  - Expected: "BrightSide sends daily positive news digests at 7 AM."
- [ ] Camera permission (if used for profile) shows custom message

### App Privacy Manifest
**Verify in App Store Connect submission:**
- [ ] Privacy Policy URL is set
- [ ] Terms of Service URL is set
- [ ] Data collection accurately disclosed (email, user ID, coarse location)
- [ ] No tracking for advertising

**Expected Behavior:**
- All legal links work
- Permission strings are clear and helpful
- Privacy manifest is accurate

---

## 11. Performance & Polish

### App Launch
- [ ] Cold start: ≤3 seconds to Today feed
- [ ] Warm start: ≤1 second to Today feed
- [ ] No white screen flash on launch

### Navigation
- [ ] Tab bar navigation is instant (<100ms)
- [ ] Back navigation is smooth
- [ ] Deep links work (if implemented)

### Images
- [ ] Story images load within 1-2 seconds
- [ ] Images cached (second view is instant)
- [ ] No broken images or loading placeholders stuck

### Memory & Battery
- [ ] App uses <100 MB memory under normal use
- [ ] No memory leaks (use Xcode Instruments)
- [ ] Battery drain is normal (no background tasks running constantly)

### UI/UX Polish
- [ ] No text truncation or overlapping UI
- [ ] Dark mode supported (if enabled)
- [ ] Pull-to-refresh works on all feeds
- [ ] Loading indicators appear for slow operations
- [ ] All buttons have appropriate touch feedback

**Expected Behavior:**
- App is fast and responsive
- No performance issues
- Professional, polished UI

---

## 12. Cross-Device & Cross-Platform

### iPhone (Multiple Sizes)
- [ ] iPhone SE (small screen) → UI adapts correctly
- [ ] iPhone 15 Pro Max (large screen) → UI looks good
- [ ] No overlapping or cut-off UI elements

### iPad (if supporting)
- [ ] iPad layout is readable (not stretched)
- [ ] Tab bar or navigation adapts to iPad size

### iOS Versions
- [ ] iOS 14 (minimum version) → app works
- [ ] iOS 17 (latest) → app works
- [ ] No deprecated API warnings

**Expected Behavior:**
- App works on all supported devices
- UI scales appropriately

---

## 13. Security & Privacy

### Data Security
- [ ] No sensitive data in logs (check Xcode console)
- [ ] No API keys or secrets in client code
- [ ] HTTPS only (no HTTP requests)

### User Privacy
- [ ] Location data is coarse (metro-level, not GPS coordinates)
- [ ] No tracking pixels or third-party analytics (beyond Firebase)
- [ ] User email not exposed in client-side code

### Firebase Security Rules
**Firestore Rules:**
- [ ] Users can only read/write their own `/users/{uid}` document
- [ ] Stories are read-only for clients
- [ ] Submissions require authentication
- [ ] Admin portal requires `admin: true` custom claim

**Expected Behavior:**
- App follows privacy best practices
- Security rules prevent unauthorized access

---

## 14. App Store Compliance

### App Store Guidelines
- [ ] No crashes or critical bugs
- [ ] All features work as described in App Store listing
- [ ] No third-party branding without permission
- [ ] No gambling, violence, or inappropriate content
- [ ] User-generated content is moderated

### Metadata Verification
- [ ] App name: "BrightSide"
- [ ] Subtitle: "Positive News from Your Community"
- [ ] Description matches actual features
- [ ] Screenshots are accurate and up-to-date
- [ ] Privacy Policy and Terms URLs are correct
- [ ] Support email works: support@brightside.com

### TestFlight Testing
- [ ] Upload build to TestFlight
- [ ] Invite 5-10 beta testers
- [ ] Collect feedback on bugs and UX
- [ ] Fix critical issues before App Store submission

**Expected Behavior:**
- App meets all App Store guidelines
- Metadata is accurate

---

## 15. Final Verification

### Pre-Submission
- [ ] Run `flutter analyze` → no errors
- [ ] Run `flutter test` → all tests pass (if tests exist)
- [ ] Build release: `flutter build ios --release -t lib/main_prod.dart`
- [ ] No debug menu in Settings (release build)
- [ ] Version number matches: pubspec.yaml = Xcode = App Store Connect
- [ ] Build number incremented from previous submission

### Post-Submission
- [ ] Monitor App Review status in App Store Connect
- [ ] Respond to reviewer questions within 24 hours
- [ ] Fix any rejection issues immediately
- [ ] Prepare marketing materials for launch

### Launch Day
- [ ] Monitor Firebase Analytics for user activity
- [ ] Monitor Crashlytics for crash reports
- [ ] Monitor support email for user questions
- [ ] Have plan for hotfix if critical bug found

**Expected Behavior:**
- Clean build with no warnings
- App is ready for App Store review

---

## Checklist Summary

**Total Sections:** 15  
**Estimated Time:** 4-6 hours (comprehensive testing)

### Critical Path
1. ✅ Environment check (`dart tool/print_env_check.dart`)
2. ✅ Onboarding flow (metro selection)
3. ✅ Auth (Google/Apple/Email)
4. ✅ Today feed (5 stories, 5 AM window)
5. ✅ Submit → Admin approve → appears in Today
6. ✅ Likes & featured stories
7. ✅ Offline caching
8. ✅ Notifications (soft-ask, 7 AM digest)
9. ✅ Account deletion cascade
10. ✅ Legal links & permission strings

### Nice-to-Have (but Recommended)
- Popular feed
- Performance testing
- Cross-device testing
- Security audit
- TestFlight beta

---

## Issue Reporting

**Found a bug during preflight?**

1. Document issue:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots/video
   - Device + iOS version

2. Categorize severity:
   - **Critical (P0):** Crash, data loss, security issue → must fix before ship
   - **High (P1):** Major feature broken → fix before ship
   - **Medium (P2):** Minor bug, UX issue → fix if time allows
   - **Low (P3):** Polish, edge case → defer to v1.1

3. Track in GitHub Issues (or preferred tracker)

---

## Sign-Off

**QA Tester:**  
Name: ________________  
Date: ________________  
Signature: ________________

**Product Owner:**  
Name: ________________  
Date: ________________  
Signature: ________________

---

**Last Updated:** 2025-01-06  
**Version:** 1.0.0  
**Status:** Ready for QA

**Questions?** support@brightside.com
