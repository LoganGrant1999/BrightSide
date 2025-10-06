# BrightSide

A Flutter app delivering positive local news across multiple metros (SLC, NYC, GSP).

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2+)
- Firebase project configured
- Firebase emulators for local development

### Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Start Firebase emulators:
```bash
cd functions
firebase emulators:start
```

3. Run the app:
```bash
flutter run
```

## Testing

### Integration Tests

Run integration tests against Firebase emulators:

```bash
# Start Firebase emulators in one terminal
firebase emulators:start

# Run integration tests in another terminal
flutter test integration_test/core_flows_test.dart
```

The integration test suite covers:
1. First run: location denial → metro picker → Today feed
2. Authentication → user document creation
3. Story submission → Firestore persistence
4. Like/unlike → state persistence across restarts
5. Metro switching → feed refresh performance

### Performance Profiling

Profile the app to check frame rendering performance:

```bash
# Run in profile mode
flutter run --profile

# Monitor frame times while scrolling Today/Popular feeds
# - Target: 60 fps (16.67ms per frame)
# - Warning: Yellow frames indicate jank (>16.67ms)
# - Error: Red frames indicate severe jank (>33.33ms)
```

**Performance sanity check:**
1. Open the app in profile mode
2. Navigate to Today tab
3. Scroll through articles smoothly
4. Check DevTools Performance tab for frame times
5. Acceptable: Most frames should be green (<16ms)
6. Investigate: Any sustained yellow/red frames

**DevTools setup:**
```bash
# Run app in profile mode
flutter run --profile

# In another terminal, open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Navigate to Performance tab and record scrolling
```

## Architecture

- **State Management**: Riverpod
- **Routing**: go_router with bottom navigation
- **Backend**: Firebase (Auth, Firestore, Functions, FCM)
- **Local Storage**: shared_preferences

## Debugging

In debug mode, Settings includes a Developer section with:
- **System Health**: View last ingest/digest times per metro
- **Fix Seed Data**: Bump article timestamps for testing
- **Delete Local Data**: Clear all local preferences

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
