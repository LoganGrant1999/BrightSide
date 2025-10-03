# BrightSide Backend Setup

This document covers Firebase backend setup for the BrightSide iOS app.

## Tech Stack

- **Firebase Authentication** - Anonymous auth (upgradeable to Google/Apple/password)
- **Cloud Firestore** - NoSQL database
- **Cloud Functions** - Serverless TypeScript functions (Node 20)
- **Cloud Storage** - Image/file storage
- **Firebase Emulators** - Local development environment

## Prerequisites

- Node.js 20+
- Firebase CLI: `npm install -g firebase-tools`
- Firebase project created (console.firebase.google.com)

## Initial Setup

### 1. Configure Project ID

Update `.firebaserc` and `firebase.json` with your actual Firebase project ID:

```bash
# In .firebaserc, replace YOUR_PROJECT_ID with your actual project ID
# Example: "default": "brightside-9a2c5"
```

### 2. Install Dependencies

```bash
# Install Cloud Functions dependencies
cd functions
npm install
cd ..

# Install seeding tool dependencies
cd tool
npm install
cd ..
```

### 3. Login to Firebase

```bash
firebase login
```

## Local Development with Emulators

### Start Emulators

```bash
firebase emulators:start --only auth,firestore,functions,storage
```

This starts:
- **Firestore** on `localhost:8080`
- **Auth** on `localhost:9099`
- **Functions** on `localhost:5001`
- **Storage** on `localhost:9199`
- **Emulator UI** on `localhost:4000` (interactive dashboard)

### Seed Local Database

With emulators running, open a new terminal:

```bash
# Set emulator environment variable
export FIRESTORE_EMULATOR_HOST="localhost:8080"

# Run seed script
cd tool
npm run seed
```

This creates:
- 3 metros (slc, nyc, gsp)
- System configuration
- Sample articles (2 per metro)

### Connect Flutter App to Emulators

In your Flutter app's Firebase initialization:

```dart
// For local development
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

## Cloud Functions

### Build Functions

```bash
cd functions
npm run build
```

### Run Tests

```bash
cd functions
npm test
```

### Watch Mode (auto-rebuild)

```bash
cd functions
npm run build:watch
```

### Lint Code

```bash
cd functions
npm run lint
npm run lint:fix  # Auto-fix issues
```

## Deployed Functions

### `onLikeCreated` (Firestore Trigger)

- **Trigger**: onCreate `/articleLikes/{likeId}`
- **Action**: Increments `articles.like_count_total` and `articles.like_count_24h`
- **Transaction**: Atomic update to prevent race conditions

### `onLikeDeleted` (Firestore Trigger)

- **Trigger**: onDelete `/articleLikes/{likeId}`
- **Action**: Decrements `articles.like_count_total` and `articles.like_count_24h`
- **Safety**: Prevents negative counts with `Math.max(0, count - 1)`

### `rotateFeaturedDaily` (Scheduled)

- **Schedule**: Daily at 12:00 UTC (05:00 America/Denver)
- **Action**:
  1. Clears old featured articles per metro
  2. Selects top 5 articles by `like_count_24h` from last 24h
  3. Sets `is_featured=true`, `featured_start`, `featured_end`

### `promoteSubmission` (Callable - Admin Only)

- **Auth**: Requires `admin: true` custom claim
- **Input**: `{ submissionId: string }`
- **Action**:
  1. Validates submission exists and status is "pending"
  2. Creates new article from submission data
  3. Updates submission with `status="approved"`, `approved_article_id`
- **Returns**: `{ success: true, articleId: string }`

## Deployment

### Deploy Everything

```bash
firebase deploy
```

### Deploy Specific Components

```bash
# Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes

# Storage rules
firebase deploy --only storage

# Cloud Functions
firebase deploy --only functions

# Specific function
firebase deploy --only functions:rotateFeaturedDaily
```

## Security Rules

### Firestore Rules (`firestore.rules`)

- `/articles` - Read all, write denied (admin/CF only)
- `/submissions` - Users create own, update own pending submissions
- `/users/{uid}` - Read/write only by that user
- `/articleLikes` - Create/delete own likes only
- `/reports` - Create if authenticated, read admin only
- `/metros` - Read all, write admin only
- `/system` - Read all, write admin only

### Storage Rules (`storage.rules`)

- `/articles/{articleId}/*` - Read all, write denied
- `/submissions/{submissionId}/attachments/*` - Read/write by submission owner only

## Database Schema

### Collections

- **articles** - Published positive news stories
- **submissions** - User-submitted stories (pending moderation)
- **users** - User profiles and preferences
- **articleLikes** - Like records (user-article pairs)
- **reports** - Flagged content reports
- **metros** - Supported metro areas
- **system** - App-wide configuration

### Key Indexes (auto-created)

1. `articles`: `(metro_id, status, publish_time DESC)` - Today query
2. `articles`: `(metro_id, status, like_count_24h DESC, publish_time DESC)` - Popular query
3. `articles`: `(metro_id, is_featured, featured_start DESC)` - Featured query

## Flutter Integration

Use the provided query builders from `lib/backend/schema_constants.dart`:

```dart
import 'package:brightside/backend/schema_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Get today's stories
final todayQuery = BrightSideQueries.todayQuery(
  FirebaseFirestore.instance,
  'slc',
);
final snapshot = await todayQuery.get();

// Get popular stories
final popularQuery = BrightSideQueries.popularQuery(
  FirebaseFirestore.instance,
  'nyc',
);

// Check if user liked an article
final likeQuery = BrightSideQueries.userLikeQuery(
  FirebaseFirestore.instance,
  userId,
  articleId,
);
final hasLiked = (await likeQuery.get()).docs.isNotEmpty;
```

## Monitoring & Logs

### View Function Logs

```bash
firebase functions:log
```

### Emulator Logs

Logs appear in the terminal where you ran `firebase emulators:start`

### Production Logs

View in Firebase Console → Functions → Logs

## Troubleshooting

### Emulators won't start

- Check ports aren't in use: `lsof -i :8080` (or other ports)
- Clear emulator data: `firebase emulators:start --import=./data --export-on-exit=./data`

### Functions not deploying

- Ensure Node version matches `functions/package.json` engines
- Run `npm install` in functions directory
- Check Firebase billing is enabled (required for Cloud Functions)

### Security rules errors

- Test rules in Emulator UI (localhost:4000) → Firestore → Rules
- Validate syntax: Rules are loaded on emulator start

### Seed script fails

- Ensure emulators are running
- Set `FIRESTORE_EMULATOR_HOST` environment variable
- Check for TypeScript compilation errors

## Next Steps

1. **Set up production project**: Replace `YOUR_PROJECT_ID` in config files
2. **Enable services**: Auth, Firestore, Functions, Storage in Firebase Console
3. **Deploy rules**: `firebase deploy --only firestore:rules,storage`
4. **Seed production data**: Run seed script against production (carefully!)
5. **Set admin claims**: Use Firebase Console → Auth → Users → Custom Claims
6. **Configure scheduled function**: rotateFeaturedDaily runs automatically once deployed

## Architecture Notes

- **Today tab**: Shows ≤ 5 most recent articles per metro
- **Popular tab**: Shows ≤ 10 articles sorted by `like_count_24h`
- **Featured rotation**: Automated daily at 5am local time per metro
- **Auth upgrade path**: Anonymous users can later link Google/Apple/password
- **Like counting**: Real-time via triggers, with 24h sliding window tracking

## Support

- Firebase Docs: https://firebase.google.com/docs
- Emulator Guide: https://firebase.google.com/docs/emulator-suite
- Cloud Functions: https://firebase.google.com/docs/functions
