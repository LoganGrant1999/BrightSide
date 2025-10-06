# App Review Instructions for Apple

This document provides detailed instructions for Apple App Review to test BrightSide.

## Test Account Credentials

**Primary Demo Account:**
```
Email:    demo@brightside.com
Password: BrightDemo2025!
```

**Account Notes:**
- Full access to all features
- No payment or subscription required (app is free)
- Pre-configured metro: **Salt Lake City (SLC)**
- Can submit stories and like articles
- Push notifications disabled by default (enable in Settings)
- Admin access available (see Admin Portal section below)

**Account Creation:**
This account is created using the developer tool:
```bash
npx ts-node tool/make_demo_reviewer.ts
```

## Demo Instructions

### First Launch Experience

1. **Open the app** - You'll see the metro selection screen
2. **Select a metro** - Choose "Salt Lake City, UT" (SLC)
   - Alternative metros: NYC (New York), GSP (Greenville-Spartanburg)
3. **Permission prompts** (may appear):
   - **Location:** Tap "Don't Allow" - You can manually select metro instead
   - **Notifications:** Tap "Allow" to test daily digest feature (optional)

### Main Features to Test

#### 1. Today Feed (Default Tab)
- Shows 5-10 positive news stories from selected metro
- Articles refresh daily at 5am local time
- Scroll through articles
- Tap any article to read full story

#### 2. Article Detail View
- Tap an article from the feed
- View story headline, summary, and source
- See published date and like count
- Tap "Read Full Story" to open source URL in browser
- Tap ❤️ to like the story
- Tap 🚩 to report (if inappropriate)

#### 3. Popular Tab
- Tap "Popular" in bottom navigation
- View most-liked stories from past 7 days
- Same interaction as Today feed

#### 4. Submit Tab
- Tap "Submit" in bottom navigation
- Fill out the submission form:
  - **Title:** "Test Article for Review"
  - **Description:** "This is a test positive news submission"
  - **Source URL:** https://example.com/positive-story
  - **Metro:** SLC (pre-selected)
- Tap "Submit"
- You'll see a confirmation message
- Submitted stories go to admin moderation queue

#### 5. Settings Tab
- Tap "Settings" in bottom navigation
- View current metro selection
- Tap "Current Metro" to change metros
- Test switching between SLC, NYC, and GSP
- View notification settings
- Tap "Sign In" to authenticate (optional)

### Sign-In Flow (Optional Testing)

#### Google Sign-In
1. Go to Settings → Tap "Sign In"
2. Choose "Continue with Google"
3. Use demo account: demo@brightside.com / BrightDemo2025!
4. Grant permissions
5. You'll be signed in and see your email in Settings

#### Apple Sign-In
1. Go to Settings → Tap "Sign In"
2. Choose "Sign in with Apple"
3. Use your Apple ID for testing
4. Choose email visibility preference
5. You'll be signed in

#### Email/Password Sign-In
1. Go to Settings → Tap "Sign In"
2. Enter: demo@brightside.com / BrightDemo2025!
3. Tap "Sign In"

### Admin Portal Testing (Optional)

To test content moderation features, the demo account can be granted admin access:

#### Grant Admin Access
**Developer must run:**
```bash
npx ts-node tool/admin_claims.ts grant demo@brightside.com
```

#### Access Admin Portal
1. **Sign out** and **sign in again** (to refresh claims)
2. Go to **Settings** → scroll to **Developer** section
3. Tap **"Admin Portal"**
4. Web portal opens in Safari

#### Test Moderation
In the Admin Portal:
- View pending user submissions
- **Approve** → Story appears in Today feed
- **Reject** → Story is hidden
- Feature articles (promote to top of Popular feed)

**Demo Submissions:**
If seeded with `--with-submissions` flag:
- 2 pending submissions from demo account
- Use these to test approval/rejection workflow

### Notification Testing

If you allowed notifications during setup:

1. **Enable notifications:**
   - Go to Settings → Notifications
   - Toggle "Daily Digest" to ON
2. **Test daily digest:**
   - You'll receive a push at 7am local time (next morning)
   - Tap the notification to open Today feed
   - Note: For immediate testing, you can wait for the scheduled time or skip this

### Metro Switching

1. Go to Settings
2. Tap "Current Metro"
3. Select a different metro (e.g., NYC)
4. Return to Today tab
5. Feed updates with NYC stories
6. Verify content changes to reflect new metro

### Location Permission Testing

1. Go to Settings
2. Toggle "Use Device Location"
3. Tap "Allow" when prompted for location access
4. App detects your location and suggests nearest metro
5. Note: May not detect exact metro if testing location is outside SLC/NYC/GSP
6. Can deny location and manually select metro instead

### Reporting & Moderation

1. Open any article
2. Tap the 🚩 (flag) icon
3. Select a reason: "Inappropriate content"
4. Tap "Submit Report"
5. See confirmation
6. Reports go to admin moderation queue

### Account Management

1. Sign in with test account
2. Go to Settings → Account
3. View account details
4. Test "Sign Out" button
5. Sign back in

### Edge Cases to Test

#### No Internet Connection
1. Turn off WiFi and cellular
2. Open app
3. See "No connection" message
4. Turn on connection
5. Content loads

#### Empty Feed (Rare)
1. If a metro has no articles (unlikely in production):
2. See "No stories today" message
3. Switch to another metro with content

#### Denied Permissions
1. Deny location when prompted
2. App still works - manually select metro
3. Deny notifications
4. App still works - no daily digest

## Known Limitations

1. **Content Updates:** Articles refresh once daily at 5am local time, not real-time
2. **Metro Coverage:** Only 3 metros supported (SLC, NYC, GSP) in v1.0
3. **Submission Approval:** User submissions require admin approval before appearing in feed
4. **Offline Mode:** App requires internet connection to load articles

## Technical Notes

### Backend Services
- **Firebase:** Used for authentication, database, storage, and push notifications
- **Cloud Functions:** Handle content moderation, RSS ingestion, and daily digests
- **Firestore:** Real-time database for articles and user data

### Privacy & Data
- Minimal data collection: email (if signed in), metro preference, device token for push
- No third-party analytics or tracking
- No ads
- User can delete account and all data from Settings

### Content Sourcing
- Articles are auto-ingested from verified RSS feeds
- Filtered for positive sentiment using keyword analysis
- Additional user-submitted content (requires moderation)
- All articles link to original source

## Support Contact

If you encounter any issues during review:

**Email:** support@brightside.com
**Response Time:** Within 24 hours

## Developer Commands Reference

For developers setting up the demo environment:

### Create Demo Account
```bash
# Basic account (no submissions)
npx ts-node tool/make_demo_reviewer.ts

# With sample submissions for moderation testing
npx ts-node tool/make_demo_reviewer.ts --with-submissions
```

### Grant/Revoke Admin Access
```bash
# Grant admin claim to demo account
npx ts-node tool/admin_claims.ts grant demo@brightside.com

# Grant admin to your own email for testing
npx ts-node tool/admin_claims.ts grant your.email@example.com

# Revoke admin claim
npx ts-node tool/admin_claims.ts revoke demo@brightside.com

# List all admins
npx ts-node tool/admin_claims.ts list
```

### Seed Test Data (Development)
```bash
# Seed articles to Firestore emulator
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_firestore.ts

# Seed RSS sources
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_sources.ts

# Run ingestion
curl "http://127.0.0.1:5001/brightside-9a2c5/us-central1/testIngest?metro=slc"
```

## Common Review Questions

**Q: Why do you need location permissions?**
A: Optional feature to auto-detect user's metro. Users can deny and manually select metro.

**Q: Why do you need notification permissions?**
A: Optional daily digest at 7am with top 3 positive stories. Users can disable anytime.

**Q: How is content moderated?**
A: Automated keyword filtering for positivity + admin review queue for user submissions + community reporting system.

**Q: What data do you collect?**
A: Email (if signed in), metro preference, device token (for push), liked articles. No tracking or analytics beyond Firebase defaults.

**Q: Is there any paid content or subscriptions?**
A: No, 100% free. No in-app purchases, no subscriptions, no ads.

## Test Checklist for Reviewers

- [ ] App launches successfully
- [ ] Metro selection works
- [ ] Today feed loads articles
- [ ] Article detail view opens
- [ ] Source URL opens in browser
- [ ] Like button works
- [ ] Report button works
- [ ] Popular tab shows stories
- [ ] Submit form accepts input
- [ ] Settings allow metro switching
- [ ] Sign-in flow works (any method)
- [ ] Notifications permission prompt appears
- [ ] App handles denied permissions gracefully
- [ ] No crashes or major bugs
- [ ] Content is appropriate (positive news only)

Thank you for reviewing BrightSide!
