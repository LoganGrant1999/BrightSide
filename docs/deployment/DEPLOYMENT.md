# Deployment Guide

This guide covers deploying BrightSide to development and production environments.

## Environment Setup

### Firebase Projects

BrightSide uses two Firebase projects:
- **dev** - Development/staging environment with emulators
- **prod** - Production environment for App Store release

Configure project aliases:
```bash
firebase use --add
# Select dev project, alias: dev
firebase use --add
# Select prod project, alias: prod
```

### Current Environment

Check active project:
```bash
firebase use
```

Switch projects:
```bash
firebase use dev
firebase use prod
```

---

## Flutter App Deployment

### Development Build

```bash
# iOS (connects to emulators)
flutter run -t lib/main_dev.dart

# Android
flutter run -t lib/main_dev.dart
```

### Production Build

```bash
# iOS (production Firebase)
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true --release

# Android
flutter build apk -t lib/main_prod.dart --dart-define=PROD=true --release
```

### App Store Submission

1. Archive in Xcode:
```bash
open ios/Runner.xcworkspace
# Product > Archive
# Ensure main_prod.dart is target
# Set --dart-define=PROD=true in build settings
```

2. Upload to App Store Connect:
```bash
# Via Xcode Organizer
# OR via Transporter app
```

---

## Admin Portal Deployment

### Development

```bash
cd admin-portal

# Run locally with emulators
npm run dev
# Uses .env.development
```

### Production

```bash
cd admin-portal

# Build for production
npm run build
# Uses .env.production

# Deploy to Firebase Hosting
cd ..
firebase deploy --only hosting
```

Access at: `https://YOUR-PROJECT.web.app/admin`

---

## Cloud Functions Deployment

### Development

```bash
cd functions

# Deploy to dev project
npm run deploy:dev
# Equivalent to:
# firebase use dev && npm run build && firebase deploy --only functions
```

### Production

```bash
cd functions

# Deploy to prod project
npm run deploy:prod
# Equivalent to:
# firebase use prod && npm run build && firebase deploy --only functions
```

### View Logs

```bash
# Dev logs
npm run logs:dev

# Prod logs
npm run logs:prod
```

---

## Firestore & Storage Rules

### Deploy Rules

```bash
# Development
firebase use dev
firebase deploy --only firestore:rules,storage

# Production
firebase use prod
firebase deploy --only firestore:rules,storage
```

---

## Full Deployment (All Services)

### Development

```bash
# Switch to dev
firebase use dev

# Deploy everything
firebase deploy
```

### Production

```bash
# Switch to prod
firebase use prod

# Deploy everything
firebase deploy
```

---

## Environment Configuration

### Flutter (.env files)

Flutter uses compile-time constants via `--dart-define`:

**Development:**
- Entrypoint: `lib/main_dev.dart`
- Environment: `AppEnv.dev`
- Emulators: Enabled
- Debug menu: Visible

**Production:**
- Entrypoint: `lib/main_prod.dart`
- Environment: `AppEnv.prod` (via `--dart-define=PROD=true`)
- Emulators: Disabled
- Debug menu: Hidden
- Crashlytics: Enabled

### Admin Portal (.env files)

**Development** (`.env.development`):
```env
NEXT_PUBLIC_USE_EMULATORS=true
NEXT_PUBLIC_FIRESTORE_EMULATOR_HOST=localhost:8080
NEXT_PUBLIC_AUTH_EMULATOR_HOST=localhost:9099
NEXT_PUBLIC_FUNCTIONS_EMULATOR_HOST=localhost:5001
```

**Production** (`.env.production`):
```env
NEXT_PUBLIC_USE_EMULATORS=false
NEXT_PUBLIC_FIREBASE_API_KEY=YOUR_PROD_KEY
NEXT_PUBLIC_FIREBASE_PROJECT_ID=brightside-prod
```

### Functions (package.json scripts)

Functions use Firebase project aliases:
- `npm run deploy:dev` → Deploys to dev project
- `npm run deploy:prod` → Deploys to prod project

---

## Seeding Data

### System Configuration

Seed system config (legal URLs, feature flags):
```bash
# Development
firebase use dev
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_system_config.ts

# Production
firebase use prod
npx ts-node tool/seed_system_config.ts
```

### RSS Sources

Seed RSS feed sources:
```bash
# Development
firebase use dev
FIRESTORE_EMULATOR_HOST="127.0.0.1:8080" npx ts-node tool/seed_sources.ts

# Production
firebase use prod
npx ts-node tool/seed_sources.ts
```

---

## Pre-Deployment Checklist

### Development
- [ ] Emulators running (`firebase emulators:start`)
- [ ] System config seeded (`seed_system_config.ts`)
- [ ] RSS sources seeded (`seed_sources.ts`)
- [ ] Functions deployed (`npm run deploy:dev`)
- [ ] Admin portal deployed (`firebase deploy --only hosting`)
- [ ] Test all flows end-to-end

### Production
- [ ] Production Firebase project created
- [ ] `.env.production` updated with real keys
- [ ] System config updated with real URLs:
  - Privacy policy URL
  - Terms of service URL
  - Support email
- [ ] RSS sources configured with real feeds
- [ ] Admin custom claims set for admins
- [ ] APNS certificates uploaded (iOS push)
- [ ] Functions deployed (`npm run deploy:prod`)
- [ ] Firestore/Storage rules deployed
- [ ] Admin portal deployed
- [ ] Flutter production build tested
- [ ] All integration tests passing

---

## Troubleshooting

### "Permission Denied" on Firestore

**Issue:** Functions can't write to Firestore

**Solution:**
```bash
# Redeploy Firestore rules
firebase deploy --only firestore:rules
```

### "Function not found" in Admin Portal

**Issue:** Callable function not deployed

**Solution:**
```bash
# Check function is exported in functions/src/index.ts
# Redeploy functions
cd functions && npm run deploy:prod
```

### Emulators Not Connecting

**Issue:** Flutter/Admin portal can't connect to emulators

**Solution:**
```bash
# Restart emulators
pkill -f firebase
firebase emulators:start

# Check environment:
# Flutter: AppEnv.isDev should be true
# Admin: NEXT_PUBLIC_USE_EMULATORS=true
```

### Admin Portal Shows Wrong Project

**Issue:** Admin portal connects to dev instead of prod

**Solution:**
```bash
# Check .env.production has correct project ID
# Rebuild and redeploy
cd admin-portal
npm run build
cd ..
firebase deploy --only hosting
```

---

## Monitoring & Logs

### Cloud Functions Logs

```bash
# Real-time logs (dev)
firebase use dev && firebase functions:log --only functionName

# Real-time logs (prod)
firebase use prod && firebase functions:log --only functionName
```

### Crashlytics (Production)

View crashes in Firebase Console:
- https://console.firebase.google.com/project/YOUR-PROJECT/crashlytics

### Analytics (Production)

View events in Firebase Console:
- https://console.firebase.google.com/project/YOUR-PROJECT/analytics

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Deploy Functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          cd functions
          npm ci
          npm run build
          firebase deploy --only functions --project prod --token $FIREBASE_TOKEN

      - name: Deploy Hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          cd admin-portal
          npm ci
          npm run build
          cd ..
          firebase deploy --only hosting --project prod --token $FIREBASE_TOKEN
```

---

## Quick Commands Reference

```bash
# Flutter
flutter run -t lib/main_dev.dart                              # Dev build
flutter build ios -t lib/main_prod.dart --dart-define=PROD=true  # Prod build

# Functions
npm run deploy:dev                                            # Deploy to dev
npm run deploy:prod                                           # Deploy to prod

# Admin Portal
npm run dev                                                   # Run dev server
npm run build && firebase deploy --only hosting              # Deploy prod

# Firebase
firebase use dev                                              # Switch to dev
firebase use prod                                             # Switch to prod
firebase deploy                                               # Deploy everything
firebase deploy --only functions                              # Functions only
firebase deploy --only hosting                                # Hosting only
firebase deploy --only firestore:rules,storage               # Rules only
```
