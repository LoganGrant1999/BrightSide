# Integration Tests

End-to-end integration tests for BrightSide app.

## Overview

These tests validate complete user flows using Firebase emulators for backend services.

## Test Files

### 1. `ingestion_today_test.dart`
Tests the ingestion → Today feed flow:
- Seed fake articles to Firestore (simulating RSS ingestion)
- Verify articles appear in Today feed
- Validate 5am rolling window logic
- Ensure published-only filtering works
- Verify daily limit (≤5 articles)

### 2. `submission_moderation_test.dart`
Tests the submission → moderation → Today flow:
- User submits story via Submit tab
- Story appears in `/submissions` with status "pending"
- Admin approves via `approveSubmission` Cloud Function
- Story moves to `/articles` with status "published"
- Story appears in Today feed
- Tests rejection flow
- Validates metro filtering

### 3. `core_flows_test.dart`
Basic user flows:
- First run with metro selection
- Authentication (Google, email)
- Submit story
- Like/unlike articles
- Metro switching

## Prerequisites

### 1. Firebase Emulators

Start all emulators before running tests:

```bash
firebase emulators:start
```

Required emulators:
- **Firestore** (port 8080)
- **Auth** (port 9099)
- **Functions** (port 5001)

### 2. Flutter Environment

Ensure Flutter is installed and configured:

```bash
flutter doctor
```

## Running Tests

### Run All Integration Tests

```bash
flutter test integration_test/
```

### Run Specific Test File

```bash
flutter test integration_test/ingestion_today_test.dart
flutter test integration_test/submission_moderation_test.dart
flutter test integration_test/core_flows_test.dart
```

### Run with Device

For tests requiring UI interaction on a real device:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/ingestion_today_test.dart
```

### Run on CI

GitHub Actions example:

```yaml
- name: Start Firebase Emulators
  run: |
    firebase emulators:start --only auth,firestore,functions &
    sleep 10

- name: Run Integration Tests
  run: flutter test integration_test/
```

## Test Helpers

The `test_helpers.dart` file provides utilities:

### Data Seeding

```dart
// Seed article
final articleId = await TestHelpers.seedArticle(
  firestore,
  title: 'Test Article',
  summary: 'Test summary',
  metroId: 'slc',
);

// Seed submission
final submissionId = await TestHelpers.seedSubmission(
  firestore,
  title: 'Test Submission',
  description: 'Test description',
  metroId: 'slc',
  userId: testUserId,
);
```

### Cleanup

```dart
// Clean up by source name
await TestHelpers.cleanupArticlesBySource(firestore, 'Test Source');

// Clean up submissions by title
await TestHelpers.cleanupSubmissionsByTitle(firestore, 'Test');

// Clean up all test data
await TestHelpers.cleanupAllTestData(firestore);
```

### Time Calculations

```dart
// Get 5am rolling window
final windowStart = TestHelpers.calculateFiveAmWindow();
```

### Authentication

```dart
// Create test user
final userId = await TestHelpers.createTestUser(auth);

// Sign in
await TestHelpers.signInTestUser(auth, email: 'test@example.com');

// Sign out
await TestHelpers.signOut(auth);
```

## Test Data Conventions

### Article Test Data

Use these source names for easy cleanup:
- `Integration Test` - General integration test articles
- `Window Test` - 5am window testing
- `Status Test` - Status filtering tests
- `Test Source` - Generic test articles

### Submission Test Data

Use these title prefixes for easy cleanup:
- `Moderation Test:` - Moderation flow tests
- `Rejection Test:` - Rejection flow tests
- `NYC Metro Test:` - Metro-specific tests

## Troubleshooting

### Emulators Not Running

Error: `Failed to connect to localhost:8080`

**Solution:**
```bash
firebase emulators:start
```

### Port Already in Use

Error: `Port 8080 is not available`

**Solution:**
```bash
# Kill existing emulator processes
pkill -f firebase
firebase emulators:start
```

### Tests Timing Out

Error: `Test timed out after 30 seconds`

**Solution:**
- Increase timeout in test:
```dart
testWidgets('test', (tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 2)));
```

### Firestore Permission Denied

Error: `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution:**
- Check Firestore rules allow emulator access
- Ensure emulator is running on correct port
- Verify `useFirestoreEmulator()` is called before any queries

### Function Not Found

Error: `Function 'approveSubmission' not found`

**Solution:**
- Ensure Functions emulator is running
- Check function is exported in `functions/src/index.ts`
- Verify `useFunctionsEmulator()` is configured

## CI/CD Integration

### GitHub Actions

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Install Functions Dependencies
        run: cd functions && npm install

      - name: Start Emulators
        run: |
          firebase emulators:start --only auth,firestore,functions &
          sleep 15

      - name: Run Integration Tests
        run: flutter test integration_test/

      - name: Stop Emulators
        if: always()
        run: pkill -f firebase || true
```

## Best Practices

### 1. Test Isolation

- Each test should clean up its own data
- Don't rely on data from previous tests
- Use unique identifiers (timestamps) for test data

### 2. Emulator Data

- Always use emulators, never production
- Reset emulator data between test runs if needed
- Use test-specific naming conventions

### 3. Async Handling

- Always await Firestore writes before assertions
- Use `pumpAndSettle()` after UI interactions
- Add delays for async operations: `await TestHelpers.waitForFirestore()`

### 4. Error Handling

- Catch and fail gracefully with descriptive messages
- Clean up data even if test fails
- Use `addTearDown()` for guaranteed cleanup

### 5. Test Data

- Use realistic but clearly identifiable test data
- Include source names/prefixes for easy cleanup
- Don't hardcode dates - use relative times

## Debugging

### Enable Verbose Logging

```bash
flutter test integration_test/ --verbose
```

### Print Firestore Data

```dart
final articles = await firestore.collection('articles').get();
for (final doc in articles.docs) {
  print('Article: ${doc.id} - ${doc.data()}');
}
```

### Check Emulator UI

Open emulator UI to inspect data:
- Firestore: http://localhost:4000/firestore
- Auth: http://localhost:4000/auth

## Coverage

Integration tests cover:

✅ Article ingestion and display
✅ User submission flow
✅ Moderation (approve/reject)
✅ Metro filtering
✅ 5am rolling window
✅ Status filtering (published only)
✅ Daily article limits
✅ Cross-metro isolation

## Contributing

When adding new integration tests:

1. Follow naming convention: `feature_flow_test.dart`
2. Use `TestHelpers` for common operations
3. Clean up all test data in `tearDown()` or test end
4. Document test purpose in file header comment
5. Update this README with new test coverage
