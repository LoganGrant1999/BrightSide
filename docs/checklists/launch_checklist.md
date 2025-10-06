# BrightSide Launch Checklist

Comprehensive pre-launch checklist mapped to PRD requirements.

## 1. Core Features (PRD Section 2.*)

### 2.1 Today Feed
- [ ] Daily articles appear in Today tab at 5am local time (rolling window)
- [ ] Articles filtered for positivity (keyword blocklist/allowlist)
- [ ] Feed shows 5-10 stories per metro per day
- [ ] Backfill logic ensures minimum 3 articles daily
- [ ] Article cards display: headline, summary, source, image, publish time
- [ ] Tap article to open detail view
- [ ] "Read Full Story" opens source URL in browser
- [ ] Pull-to-refresh works
- [ ] Empty state shows helpful message

### 2.2 Popular Feed
- [ ] Popular tab shows top stories by likes (7-day window)
- [ ] Sorted by like_count descending
- [ ] Same article card design as Today
- [ ] Empty state if no popular stories

### 2.3 Article Detail
- [ ] Full article view with headline, summary, source, image
- [ ] Like button (heart icon) toggles on/off
- [ ] Like count updates in real-time
- [ ] Report button (flag icon) opens report dialog
- [ ] Share button copies article URL or opens share sheet
- [ ] Source attribution visible and clickable
- [ ] Publish date displayed
- [ ] Back navigation works

### 2.4 Submit Story
- [ ] Submit tab accessible from bottom nav
- [ ] Form fields: title, description, source URL, metro
- [ ] Metro auto-selected based on user's current metro
- [ ] Photo upload optional (not MVP)
- [ ] Validation: all fields required except photo
- [ ] Success message on submission
- [ ] Submission status shows "pending" in user's submissions list
- [ ] Admin receives submission in moderation queue

### 2.5 Metro Selection
- [ ] First-time users see metro picker
- [ ] Metro picker shows: SLC, NYC, GSP
- [ ] Metro icons/images display correctly
- [ ] Selection saves to SharedPreferences
- [ ] Settings allows metro switching
- [ ] Feed updates when metro changes
- [ ] Optional: "Use Device Location" auto-detects metro
- [ ] Location permission denial handled gracefully

### 2.6 Notifications
- [ ] Permission prompt on first feed view (after delay)
- [ ] Daily digest at 7am local time
- [ ] Digest shows top 3 articles in notification
- [ ] Tap notification opens Today tab
- [ ] Single-article push opens article detail
- [ ] Settings toggle to enable/disable notifications
- [ ] Notification icon and sound configured
- [ ] Background notification handling works
- [ ] Analytics logged on notification tap

### 2.7 Featured Articles
- [ ] Featured articles show star badge in feed
- [ ] Admin can manually pin articles (featured_end=null)
- [ ] Scheduler rotates auto-featured articles daily at 6am
- [ ] Manual pins persist until unfeatured by admin
- [ ] Featured rotation skips manual pins
- [ ] Top 3 articles featured per metro based on like_count
- [ ] Featured articles appear at top of feed

### 2.8 User Authentication
- [ ] Optional sign-in (Guest mode supported)
- [ ] Sign in with Google
- [ ] Sign in with Apple
- [ ] Email/password sign-in
- [ ] Account creation flow
- [ ] Password reset flow
- [ ] Sign out functionality
- [ ] User profile shows email, metro preference
- [ ] Liked articles persist across devices when signed in
- [ ] Delete account option in Settings

### 2.9 Content Moderation
- [ ] Report button on all articles
- [ ] Report reasons: inappropriate, spam, misinformation, other
- [ ] Reports appear in admin portal /reports page
- [ ] Admin can triage reports (new → reviewing → closed)
- [ ] Flagged articles show warning badge (admin only)
- [ ] User submissions auto-flagged for moderation
- [ ] Admin approve/reject flow works

## 3. Technical Requirements (PRD Section 3.*)

### 3.1 Flutter App
- [ ] Minimum iOS version: 14.0
- [ ] Minimum Android version: API 21 (Lollipop)
- [ ] Riverpod state management configured
- [ ] go_router navigation configured
- [ ] Null safety enabled
- [ ] No compiler warnings or errors
- [ ] Runs on physical iOS devices
- [ ] Runs on physical Android devices
- [ ] Dark mode support (optional MVP)
- [ ] Responsive layout for tablets

### 3.2 Firebase Setup
- [ ] Firebase project created (production)
- [ ] iOS app configured in Firebase Console
- [ ] Android app configured in Firebase Console
- [ ] GoogleService-Info.plist in ios/Runner/
- [ ] google-services.json in android/app/
- [ ] Firebase Auth enabled (Google, Apple, Email)
- [ ] Firestore database created
- [ ] Firestore security rules deployed
- [ ] Storage bucket configured
- [ ] Storage security rules deployed
- [ ] Cloud Functions deployed
- [ ] Firebase Crashlytics enabled
- [ ] Firebase Analytics enabled
- [ ] Firebase Messaging (FCM) enabled

### 3.3 Backend (Cloud Functions)
- [ ] Node 20 runtime configured
- [ ] Firebase Admin SDK v12+ with v1 Message API
- [ ] All functions deploy without errors
- [ ] Scheduled functions:
  - [ ] ingestSlc (04:40 America/Denver)
  - [ ] ingestNyc (04:40 America/New_York)
  - [ ] ingestGsp (04:40 America/New_York)
  - [ ] digestSlc (07:00 America/Denver)
  - [ ] digestNyc (07:00 America/New_York)
  - [ ] digestGsp (07:00 America/New_York)
  - [ ] rotateFeaturedSlc (06:00 America/Denver)
  - [ ] rotateFeaturedNyc (06:00 America/New_York)
  - [ ] rotateFeaturedGsp (06:00 America/New_York)
- [ ] Callable functions:
  - [ ] approveSubmission
  - [ ] rejectSubmission
  - [ ] featureArticle
  - [ ] deleteAccount
- [ ] Health monitoring writes to /system/health
- [ ] RSS ingestion runs and populates articles
- [ ] Positivity filter works (blocklist/allowlist)
- [ ] Backfill logic ensures minimum articles
- [ ] Deduplication by source_url works

### 3.4 Admin Portal (Next.js)
- [ ] Next.js app builds successfully
- [ ] Deployed to Firebase Hosting at /admin
- [ ] Login page with Google Sign-In
- [ ] Admin custom claim verification works
- [ ] Unauthorized page for non-admins
- [ ] /admin/submissions page lists pending submissions
- [ ] Approve/reject buttons call Cloud Functions
- [ ] /admin/reports page lists open reports
- [ ] Triage status updates (new → reviewing → closed)
- [ ] /admin/articles page lists all articles by metro
- [ ] Feature/unfeature toggle works
- [ ] Manual pins persist until unfeatured
- [ ] Navigation between pages works
- [ ] Sign out button works
- [ ] Environment variables configured

### 3.5 Security & Privacy
- [ ] Firestore rules prevent unauthorized writes
- [ ] Firestore rules allow read for published articles only
- [ ] Storage rules prevent unauthorized uploads
- [ ] Admin-only functions verify custom claim
- [ ] User data isolated by UID
- [ ] No sensitive data in client code
- [ ] API keys restricted (Firebase, Google, Apple)
- [ ] Privacy policy URL set
- [ ] Terms of service URL set
- [ ] GDPR/CCPA compliance documented
- [ ] Data deletion on account delete

### 3.6 Content & RSS
- [ ] RSS sources seeded in /system/sources/{metro}/sources
- [ ] At least 3 RSS feeds per metro
- [ ] RSS parser handles various feed formats
- [ ] Image extraction works (enclosure, media:content)
- [ ] Summary/description extraction works
- [ ] HTML stripping in summaries
- [ ] Publish time parsing handles timezones
- [ ] Source URL validation
- [ ] Daily limit (8 articles) enforced
- [ ] 48-hour backfill works when needed

### 3.7 Analytics & Monitoring
- [ ] Firebase Analytics events:
  - [ ] app_open
  - [ ] metro_set
  - [ ] article_open
  - [ ] notif_open (with metro_id, article_id)
- [ ] User properties set (metro, user_id)
- [ ] Firebase Crashlytics catches crashes
- [ ] Test crash works in debug mode
- [ ] Health monitoring dashboard readable
- [ ] Function logs accessible in Firebase Console
- [ ] Error alerting configured (optional)

## 4. App Store Submission (PRD Section 4.*)

### 4.1 App Store Connect Setup
- [ ] Apple Developer account enrolled
- [ ] App ID created (com.brightside.app or similar)
- [ ] App created in App Store Connect
- [ ] Bundle ID matches iOS project
- [ ] Version 1.0.0 configured
- [ ] Build uploaded via Xcode or Transporter

### 4.2 App Metadata
- [ ] App name: "BrightSide"
- [ ] Subtitle: "Positive Local News Daily"
- [ ] Description copied from docs/app-store/metadata.md
- [ ] Keywords set (100 char max)
- [ ] Primary category: News
- [ ] Secondary category: Lifestyle
- [ ] Age rating: 4+
- [ ] Privacy policy URL set
- [ ] Terms of service URL set
- [ ] Support URL set
- [ ] Marketing URL set (optional)

### 4.3 App Icon & Screenshots
- [ ] App icon generated (1024x1024px)
- [ ] Icon uploaded to App Store Connect
- [ ] iOS 6.7" screenshots (1290x2796) - 5 required
- [ ] iOS 6.5" screenshots (1284x2778) - optional
- [ ] iOS 5.5" screenshots (1242x2208) - optional
- [ ] iPad screenshots (2048x2732) - optional
- [ ] App preview video uploaded (optional)
- [ ] Screenshots show app in light mode
- [ ] Screenshots don't violate Apple guidelines

### 4.4 App Review Info
- [ ] Test account credentials provided
- [ ] Demo instructions in App Review Notes
- [ ] Review instructions copied from docs/app-store/review_instructions.md
- [ ] Test accounts work (can sign in, use features)
- [ ] App works on Apple's test devices
- [ ] No crashes on iOS 14+ devices

### 4.5 Build & Signing
- [ ] iOS build compiles with release config
- [ ] Code signing certificates valid
- [ ] Provisioning profiles configured
- [ ] Archive created in Xcode
- [ ] Build uploaded to App Store Connect
- [ ] Build status: "Ready for Review"
- [ ] All required capabilities enabled (Push, Sign in with Apple)

### 4.6 Privacy Nutrition Labels
- [ ] Data collection disclosed:
  - [ ] Email (if signed in)
  - [ ] Device ID (for push notifications)
  - [ ] Location (optional, for metro detection)
  - [ ] User content (liked articles, submissions)
- [ ] Data linked to user vs. not linked
- [ ] Tracking disclosure (none)
- [ ] Third-party SDKs disclosed (Firebase, Google, Apple)

## 5. Testing & QA (PRD Section 5.*)

### 5.1 Functional Testing
- [ ] All user flows tested on iOS
- [ ] All user flows tested on Android
- [ ] Sign-in flows (Google, Apple, Email) tested
- [ ] Metro switching tested
- [ ] Article liking/unliking tested
- [ ] Submission form tested
- [ ] Report form tested
- [ ] Notification tap routing tested
- [ ] Deep linking tested (if applicable)
- [ ] Offline behavior tested
- [ ] Network error handling tested

### 5.2 Performance Testing
- [ ] App launch time < 3 seconds
- [ ] Feed loads in < 2 seconds
- [ ] Article detail loads instantly
- [ ] Image loading optimized (cached)
- [ ] No memory leaks
- [ ] Smooth scrolling (60fps)
- [ ] No ANR (Android) or freezes (iOS)
- [ ] Battery usage acceptable

### 5.3 Edge Case Testing
- [ ] Empty feed handled gracefully
- [ ] No internet connection handled
- [ ] Invalid data from backend handled
- [ ] Permission denials handled
- [ ] Sign-in failures handled
- [ ] Submission failures handled
- [ ] Notification failures handled
- [ ] Metro with no articles handled

### 5.4 Device Testing
- [ ] iPhone 12+ (iOS 14-17)
- [ ] iPad (iOS 14+)
- [ ] Android Pixel (Android 10+)
- [ ] Android Samsung (Android 10+)
- [ ] Various screen sizes tested
- [ ] Dark mode tested (if supported)
- [ ] Accessibility tested (VoiceOver, TalkBack)

### 5.5 Integration Testing
- [ ] Firebase Auth integration works
- [ ] Firestore reads/writes work
- [ ] Cloud Functions callable works
- [ ] Storage uploads work (if applicable)
- [ ] FCM push notifications deliver
- [ ] Analytics events log correctly
- [ ] Crashlytics reports crashes

## 6. Documentation (PRD Section 6.*)

### 6.1 User Documentation
- [ ] README.md in repo root
- [ ] docs/app-store/metadata.md complete
- [ ] docs/app-store/review_instructions.md complete
- [ ] docs/app-store/privacy_policy_url.txt updated
- [ ] docs/app-store/terms_url.txt updated
- [ ] In-app help text reviewed

### 6.2 Developer Documentation
- [ ] Setup instructions in README
- [ ] Flutter version specified
- [ ] Firebase setup documented
- [ ] Environment variables documented
- [ ] Build commands documented
- [ ] Deployment process documented
- [ ] Architecture diagram (optional)

### 6.3 Code Quality
- [ ] No linter warnings
- [ ] No compiler errors
- [ ] Code formatted (dart format)
- [ ] No TODO comments for critical issues
- [ ] Tests pass (if any)
- [ ] Integration tests pass (if any)

## 7. Pre-Launch Final Checks

### 7.1 Production Environment
- [ ] Firebase project set to production
- [ ] Production API keys configured
- [ ] Production database has seed data
- [ ] Production functions deployed
- [ ] Production hosting deployed (admin portal)
- [ ] Production RSS sources active
- [ ] Production schedulers running
- [ ] Production notifications sending

### 7.2 Compliance & Legal
- [ ] Privacy policy live and accessible
- [ ] Terms of service live and accessible
- [ ] EULA accepted (if required)
- [ ] Age rating accurate
- [ ] Content rating accurate
- [ ] Export compliance declared
- [ ] Encryption declaration filed

### 7.3 Marketing & Launch
- [ ] App Store listing finalized
- [ ] Screenshots uploaded
- [ ] App icon finalized
- [ ] Press kit prepared (optional)
- [ ] Social media accounts created (optional)
- [ ] Support email active
- [ ] Landing page live (optional)

### 7.4 Monitoring & Support
- [ ] Crashlytics dashboard monitored
- [ ] Analytics dashboard monitored
- [ ] Support email monitored
- [ ] App review ratings monitored
- [ ] Function logs monitored
- [ ] Error budget defined
- [ ] Incident response plan ready

## 8. Post-Launch (PRD Section 7.*)

### 8.1 First 24 Hours
- [ ] Monitor for crashes (Crashlytics)
- [ ] Monitor for errors (Cloud Functions logs)
- [ ] Verify schedulers running (health monitoring)
- [ ] Verify notifications sending
- [ ] Check App Store reviews
- [ ] Respond to user feedback
- [ ] Fix critical bugs immediately

### 8.2 First Week
- [ ] Analyze user retention (Analytics)
- [ ] Review feature usage (Analytics events)
- [ ] Gather user feedback
- [ ] Plan iteration 1 features
- [ ] Address any App Store review issues
- [ ] Update documentation as needed

### 8.3 First Month
- [ ] Analyze growth metrics
- [ ] Plan metro expansion (if successful)
- [ ] Refine content curation
- [ ] Optimize performance
- [ ] Consider feature requests
- [ ] Prepare v1.1 release

## Notes

- This checklist maps to PRD sections 2.* (Core Features) and 3.* (Technical Requirements)
- Check off items as completed
- Use for final pre-submission review
- Keep updated as features change
- Add notes for any skipped items

**Last Updated:** 2025-10-03
**Version:** 1.0.0
