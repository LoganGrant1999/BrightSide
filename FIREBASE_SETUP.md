# Firebase Setup & Development Guide

## Overview

BrightSide uses Firebase for:
- **Authentication**: Anonymous auth (auto-created on app start)
- **Firestore**: Real-time database for articles, submissions, and user profiles
- **Cloud Functions**: Backend logic for likes, featured article rotation, and admin tools
- **Storage**: Photo uploads for user submissions

## Initial Setup

### 1. Firebase Project

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in the project
firebase init
# Select: Firestore, Functions, Storage
```

### 2. Configure Environment

```bash
# Set admin token for debug tools (choose a long random string)
firebase functions:config:set admin.fix_seed_token="YOUR_LONG_RANDOM_TOKEN"

# Update lib/features/settings/settings_screen.dart
# Replace 'YOUR_LONG_RANDOM_TOKEN' with your actual token
```

### 3. Deploy Functions

```bash
cd functions
npm install
cd ..

# Deploy all functions
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:likeArticle
firebase deploy --only functions:fixSeedForMetro
firebase deploy --only functions:rotateFeaturedDaily
```

### 4. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

## Seeding Test Data

### Option 1: Run Dart Seed Script

```bash
# Seed sample articles (9 articles total - 3 per metro)
dart run tool/seed_firestore.dart
```

### Option 2: Use In-App Debug Tool (Recommended)

1. Run the app in debug mode
2. Navigate to Settings screen
3. Tap **[DEBUG] Fix seed for current metro**
4. This will:
   - Ensure all articles have `status: 'published'`
   - Set `featured: false` if missing
   - Bump `publishedAt` to recent timestamps (within last 7 days)

### Backfill Workflow

If your seeded articles aren't showing up in the "Today" tab:

1. **Set the token** (one-time):
   ```bash
   firebase functions:config:set admin.fix_seed_token="YOUR_LONG_RANDOM_TOKEN"
   firebase deploy --only functions:fixSeedForMetro
   ```

2. **Run the app** (debug build)

3. **Open Settings** → Tap **"[DEBUG] Fix seed for current metro"**

4. **Refresh the Today tab** (pull to refresh)
   - You should now see up to 5 stories from the last 24 hours
   - Or the latest 5 via fallback if none in last 24h

## Environment Variables

The app respects the following compile-time constants:

```bash
# Enable Firebase backend (instead of mock repositories)
flutter run --dart-define=BRIGHTSIDE_USE_FIREBASE=true

# For iOS
flutter build ios --dart-define=BRIGHTSIDE_USE_FIREBASE=true
```

## Cloud Functions

### likeArticle (Callable)

**Purpose**: Toggle like/unlike on articles

**Auth**: Requires authenticated user

**Validation**:
- Article must exist
- Article must not be featured

**Behavior**:
- Creates/removes like in `articleLikes` collection
- Atomically increments/decrements `likeCount` on article
- Returns updated like count

### fixSeedForMetro (Callable - Admin Only)

**Purpose**: Backfill/fix seed data for development

**Auth**: Requires authenticated user + admin token

**Parameters**:
- `metroId`: string (required) - Metro to fix
- `limit`: number (optional, default 25, max 100)
- `token`: string (required) - Must match `FIX_SEED_TOKEN` env var

**Behavior**:
- Finds up to `limit` articles for the metro
- For each article:
  - Sets `status: 'published'` if not already
  - Sets `featured: false` if missing
  - Sets `publishedAt` to server timestamp if missing/old (>7 days)
- Returns `{ updatedCount: number }`

### rotateFeaturedDaily (Scheduled)

**Purpose**: Automatically rotate featured articles

**Schedule**: Every day at 00:05 UTC

**Behavior**:
- For each metro (SLC, NYC, GSP):
  - Queries top 5 articles by likes from last 30 days
  - Clears existing featured flags
  - Sets new top 5 as featured

## Firestore Collections

### articles
- **Access**: Public read, admin write only
- **Fields**: id, metroId, state, city, title, snippet, body, imageUrl, authorUid, authorName, likeCount, featured, featuredAt, publishedAt, status

### submissions
- **Access**: Authenticated users can read and create their own
- **Fields**: id, submittedByUid, title, desc, city, state, when, photoUrl, status, createdAt

### users
- **Access**: Public read, users can update their own
- **Fields**: uid, displayName, photoURL, bio, city, state, createdAt, lastSeenAt, roles, stats

### articleLikes
- **Access**: Public read, authenticated users can create/delete their own
- **Fields**: uid, articleId, createdAt

### reports
- **Access**: Admin read only, authenticated users can create
- **Fields**: articleId, uid, reason, details, createdAt

## Firestore Indexes

Required composite indexes:

```
Collection: articles
- metroId (=) + status (=) + publishedAt (↓)
- metroId (=) + status (=) + featured (=) + featuredAt (↓)
- metroId (=) + status (=) + publishedAt (≥) + publishedAt (↓)
```

Create these via Firebase Console when prompted, or add to `firestore.indexes.json`.

## Development Tips

### Testing Firebase Functions Locally

```bash
# Start Firebase emulators
cd functions
npm run serve

# In another terminal, run the app pointing to emulators
flutter run --dart-define=FIRESTORE_EMULATOR_HOST=localhost:8080
```

### Viewing Logs

```bash
# View function logs
firebase functions:log

# Stream logs in real-time
firebase functions:log --only likeArticle
```

### Common Issues

**Issue**: "No stories yet" in Today tab
- **Solution**: Run the debug seed fix tool in Settings

**Issue**: Firestore permission denied
- **Solution**: Check that Firebase rules are deployed: `firebase deploy --only firestore:rules`

**Issue**: Function not found
- **Solution**: Deploy functions: `firebase deploy --only functions`

**Issue**: Like button shows "failed-precondition"
- **Solution**: Article is featured - likes are paused for featured articles

## Security Notes

- The `FIX_SEED_TOKEN` is for development only
- Never commit tokens to version control
- Use environment-specific Firebase projects (dev, staging, prod)
- Rotate tokens periodically
- Remove debug tools before production release

## Next Steps

1. Set up production Firebase project
2. Configure CI/CD for automatic function deployments
3. Set up Firebase Crashlytics for error tracking
4. Configure Firebase Analytics for usage metrics
5. Implement proper user authentication (email/social)
