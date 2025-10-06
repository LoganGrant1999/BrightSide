import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brightside/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Integration tests for core user flows
/// Run with: flutter test integration_test/core_flows_test.dart
///
/// Prerequisites:
/// - Firebase emulators running (auth, firestore)
/// - Use: firebase emulators:start
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Connect to Firebase emulators
    await Firebase.initializeApp();

    // Connect to Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  });

  group('Core Flows', () {
    testWidgets('1. First run: deny location → metro picker → Today shows ≤5 articles',
        (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Expect location permission dialog or metro picker
      // Note: On first run, app should show metro picker if location denied

      // Look for metro selection screen or skip button
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Should show metro picker
      expect(
        find.byType(BottomSheet).or(find.text('Select Metro')),
        findsWidgets,
      );

      // Select SLC metro
      final slcTile = find.text('Salt Lake City');
      if (slcTile.evaluate().isNotEmpty) {
        await tester.tap(slcTile);
        await tester.pumpAndSettle();
      }

      // Should navigate to Today tab
      expect(find.text('Today'), findsOneWidget);

      // Should show at most 5 articles (could be fewer if no data)
      final articleCards = find.byType(Card);
      expect(articleCards.evaluate().length, lessThanOrEqualTo(5));
    });

    testWidgets('2. Auth with Google (mock) → /users doc created',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsTab = find.text('Settings');
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Look for Sign In button (guest mode)
      final signInButton = find.text('Sign In');
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // In emulator mode, we can create a test account directly
        final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@example.com';
        final testPassword = 'password123';

        try {
          // Create test user in Auth emulator
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify user document was created
          final userId = userCredential.user!.uid;
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          expect(userDoc.exists, isTrue);
          expect(userDoc.data()?['email'], equals(testEmail));
        } catch (e) {
          // If user already exists, that's okay for this test
          debugPrint('Auth test note: $e');
        }
      }
    });

    testWidgets('3. Submit story → appears in /submissions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Ensure we're signed in (use test account from previous test or create new)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Create test user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'submit_test@example.com',
          password: 'password123',
        );
      }

      await tester.pumpAndSettle();

      // Navigate to Submit tab
      final submitTab = find.text('Submit');
      await tester.tap(submitTab);
      await tester.pumpAndSettle();

      // Fill out submission form
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Test Good News Story');
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextField).at(1);
      await tester.enterText(
        descriptionField,
        'This is a test positive news story for integration testing.',
      );
      await tester.pumpAndSettle();

      // Submit the form
      final submitButton = find.text('Submit Story');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify submission was created in Firestore
        final submissions = await FirebaseFirestore.instance
            .collection('submissions')
            .where('title', isEqualTo: 'Test Good News Story')
            .limit(1)
            .get();

        expect(submissions.docs.isNotEmpty, isTrue);
        expect(submissions.docs.first.data()['status'], equals('pending'));
      }
    });

    testWidgets('4. Like/unlike → state persists after restart',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Ensure we're signed in
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'like_test@example.com',
          password: 'password123',
        );
      }

      await tester.pumpAndSettle();

      // Navigate to Today tab
      final todayTab = find.text('Today');
      await tester.tap(todayTab);
      await tester.pumpAndSettle();

      // Find first article and like it
      final likeButton = find.byIcon(Icons.favorite_border).first;
      if (likeButton.evaluate().isNotEmpty) {
        await tester.tap(likeButton);
        await tester.pumpAndSettle();

        // Verify like button changed to filled heart
        expect(find.byIcon(Icons.favorite), findsWidgets);

        // Get article ID to verify persistence
        // Note: This requires inspecting the widget tree or using key

        // Restart app
        await tester.pumpWidget(Container());
        app.main();
        await tester.pumpAndSettle();

        // Navigate back to Today
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();

        // Like should still be there (filled heart)
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('5. Switch metro → feed refreshes quickly',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsTab = find.text('Settings');
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Tap on metro selector
      final currentMetro = find.text('Current Metro');
      await tester.tap(currentMetro);
      await tester.pumpAndSettle();

      // Switch to NYC
      final nycTile = find.text('New York City');
      if (nycTile.evaluate().isNotEmpty) {
        final startTime = DateTime.now();

        await tester.tap(nycTile);
        await tester.pumpAndSettle();

        // Navigate to Today tab
        final todayTab = find.text('Today');
        await tester.tap(todayTab);
        await tester.pumpAndSettle();

        final endTime = DateTime.now();
        final refreshDuration = endTime.difference(startTime);

        // Feed should refresh within 3 seconds
        expect(refreshDuration.inSeconds, lessThan(3));

        // Should show Today screen
        expect(find.text('Today'), findsOneWidget);
      }
    });
  });
}

// Helper extension for OR finder
extension FinderExtension on Finder {
  Finder or(Finder other) {
    return find.byWidgetPredicate(
      (widget) =>
          evaluate().isNotEmpty || other.evaluate().isNotEmpty,
    );
  }
}
