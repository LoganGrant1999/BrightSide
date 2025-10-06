import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brightside/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Integration test: Submission → Moderation → Today Feed
///
/// Tests the end-to-end flow from user submission to approval and display.
///
/// Flow:
/// 1. User submits story via Submit tab
/// 2. Story appears in /submissions with status "pending"
/// 3. Admin calls approveSubmission Cloud Function (via emulator)
/// 4. Story moves to /articles with status "published"
/// 5. Story appears in Today feed
///
/// Prerequisites:
/// - Firebase emulators running: firebase emulators:start
/// - Firestore emulator on localhost:8080
/// - Auth emulator on localhost:9099
/// - Functions emulator on localhost:5001
///
/// Run with: flutter test integration_test/submission_moderation_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late FirebaseFunctions functions;
  late String testUserId;

  setUpAll(() async {
    // Connect to Firebase emulators
    await Firebase.initializeApp();

    // Connect to Firestore emulator
    firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator('localhost', 8080);

    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    // Connect to Functions emulator
    functions = FirebaseFunctions.instance;
    functions.useFunctionsEmulator('localhost', 5001);

    // Create test user
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'submission_test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'password123',
      );
      testUserId = userCredential.user!.uid;
    } catch (e) {
      // User might already exist
      testUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    }
  });

  group('Submission → Moderation Integration', () {
    testWidgets(
      'Submit story → appears in /submissions with status pending',
      (WidgetTester tester) async {
        // Ensure we're signed in
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'submission_test@example.com',
            password: 'password123',
          );
        }

        // Launch app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Select metro if needed
        final slcMetroFinder = find.text('Salt Lake City');
        if (slcMetroFinder.evaluate().isNotEmpty) {
          await tester.tap(slcMetroFinder);
          await tester.pumpAndSettle();
        }

        // Navigate to Submit tab
        final submitTab = find.text('Submit');
        expect(submitTab, findsOneWidget);
        await tester.tap(submitTab);
        await tester.pumpAndSettle();

        // Fill out submission form
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, 'Moderation Test: Local Hero Saves Cat');
        await tester.pumpAndSettle();

        // Find description field (usually second TextField)
        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(
          descriptionField,
          'A brave local resident rescued a cat from a tree, bringing joy to the neighborhood.',
        );
        await tester.pumpAndSettle();

        // Find source URL field (usually third TextField)
        final sourceField = find.byType(TextField).at(2);
        await tester.enterText(sourceField, 'https://example.com/hero-cat');
        await tester.pumpAndSettle();

        // Submit the form
        final submitButton = find.widgetWithText(ElevatedButton, 'Submit Story');
        if (submitButton.evaluate().isEmpty) {
          // Try alternative button text
          final altSubmitButton = find.widgetWithText(ElevatedButton, 'Submit');
          await tester.tap(altSubmitButton);
        } else {
          await tester.tap(submitButton);
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify submission was created in Firestore
        final submissions = await firestore
            .collection('submissions')
            .where('title', isEqualTo: 'Moderation Test: Local Hero Saves Cat')
            .limit(1)
            .get();

        expect(submissions.docs.isNotEmpty, isTrue, reason: 'Submission should be created in Firestore');

        final submissionDoc = submissions.docs.first;
        final submissionData = submissionDoc.data();

        expect(submissionData['status'], equals('pending'), reason: 'Submission status should be pending');
        expect(submissionData['metro_id'], equals('slc'), reason: 'Submission should have SLC metro');
        expect(submissionData['submittedByUid'], isNotEmpty, reason: 'Submission should have user ID');

        // Verify no article exists yet
        final articles = await firestore
            .collection('articles')
            .where('title', isEqualTo: 'Moderation Test: Local Hero Saves Cat')
            .limit(1)
            .get();

        expect(articles.docs.isEmpty, isTrue, reason: 'Article should not exist before approval');

        // Clean up will happen in next test after approval
      },
    );

    testWidgets(
      'Call approveSubmission → story moves to /articles and appears in Today',
      (WidgetTester tester) async {
        // Find the submission we created
        final submissions = await firestore
            .collection('submissions')
            .where('title', isEqualTo: 'Moderation Test: Local Hero Saves Cat')
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

        if (submissions.docs.isEmpty) {
          fail('No pending submission found. Run previous test first.');
        }

        final submissionId = submissions.docs.first.id;
        final submissionData = submissions.docs.first.data();

        // Call approveSubmission Cloud Function via emulator
        try {
          final approveSubmission = functions.httpsCallable('approveSubmission');
          final result = await approveSubmission.call({
            'submissionId': submissionId,
            'publishNow': true,
          });

          expect(result.data['success'], isTrue, reason: 'approveSubmission should succeed');

          final articleId = result.data['articleId'];
          expect(articleId, isNotEmpty, reason: 'Should return article ID');

          // Give Firestore time to process
          await Future.delayed(const Duration(seconds: 1));

          // Verify submission status updated to "approved"
          final updatedSubmission = await firestore
              .collection('submissions')
              .doc(submissionId)
              .get();

          expect(updatedSubmission.data()?['status'], equals('approved'));
          expect(updatedSubmission.data()?['approved_article_id'], equals(articleId));

          // Verify article was created in /articles
          final article = await firestore
              .collection('articles')
              .doc(articleId)
              .get();

          expect(article.exists, isTrue, reason: 'Article should be created');

          final articleData = article.data()!;
          expect(articleData['title'], equals(submissionData['title']));
          expect(articleData['summary'], equals(submissionData['desc']));
          expect(articleData['metro_id'], equals(submissionData['metro_id']));
          expect(articleData['status'], equals('published'));
          expect(articleData['source_name'], equals('User Submission'));

          // Launch app to verify article appears in Today feed
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Select SLC metro if needed
          final slcMetroFinder = find.text('Salt Lake City');
          if (slcMetroFinder.evaluate().isNotEmpty) {
            await tester.tap(slcMetroFinder);
            await tester.pumpAndSettle();
          }

          // Ensure we're on Today tab
          final todayTab = find.text('Today');
          if (todayTab.evaluate().isNotEmpty) {
            await tester.tap(todayTab);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          // Verify article appears in Today feed
          expect(
            find.textContaining('Moderation Test: Local Hero Saves Cat'),
            findsOneWidget,
            reason: 'Approved article should appear in Today feed',
          );

          // Clean up test data
          await firestore.collection('articles').doc(articleId).delete();
          await firestore.collection('submissions').doc(submissionId).delete();
        } catch (e) {
          fail('approveSubmission failed: $e');
        }
      },
    );

    testWidgets(
      'Call rejectSubmission → submission status updated, no article created',
      (WidgetTester tester) async {
        // Create a new submission to reject
        final rejectionSubmission = {
          'title': 'Rejection Test: Story to Reject',
          'desc': 'This story will be rejected for testing.',
          'metro_id': 'slc',
          'source_url': 'https://example.com/reject',
          'submittedByUid': testUserId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        final submissionRef = await firestore.collection('submissions').add(rejectionSubmission);
        final submissionId = submissionRef.id;

        await Future.delayed(const Duration(milliseconds: 500));

        // Call rejectSubmission Cloud Function
        try {
          final rejectSubmission = functions.httpsCallable('rejectSubmission');
          final result = await rejectSubmission.call({
            'submissionId': submissionId,
            'reason': 'Not positive enough for integration test',
          });

          expect(result.data['success'], isTrue, reason: 'rejectSubmission should succeed');

          // Give Firestore time to process
          await Future.delayed(const Duration(seconds: 1));

          // Verify submission status updated to "rejected"
          final updatedSubmission = await firestore
              .collection('submissions')
              .doc(submissionId)
              .get();

          expect(updatedSubmission.data()?['status'], equals('rejected'));
          expect(
            updatedSubmission.data()?['rejection_reason'],
            equals('Not positive enough for integration test'),
          );

          // Verify NO article was created
          final articles = await firestore
              .collection('articles')
              .where('title', isEqualTo: 'Rejection Test: Story to Reject')
              .limit(1)
              .get();

          expect(articles.docs.isEmpty, isTrue, reason: 'No article should be created for rejected submission');

          // Clean up
          await firestore.collection('submissions').doc(submissionId).delete();
        } catch (e) {
          fail('rejectSubmission failed: $e');
        }
      },
    );

    testWidgets(
      'Approved article appears immediately in Today feed with correct metro filtering',
      (WidgetTester tester) async {
        // Create submission for NYC metro
        final nycSubmission = {
          'title': 'NYC Metro Test: Brooklyn Bridge Cleanup',
          'desc': 'Community volunteers clean up Brooklyn Bridge.',
          'metro_id': 'nyc',
          'source_url': 'https://example.com/nyc-cleanup',
          'submittedByUid': testUserId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        };

        final submissionRef = await firestore.collection('submissions').add(nycSubmission);
        final submissionId = submissionRef.id;

        await Future.delayed(const Duration(milliseconds: 500));

        // Approve submission
        final approveSubmission = functions.httpsCallable('approveSubmission');
        final result = await approveSubmission.call({
          'submissionId': submissionId,
          'publishNow': true,
        });

        final articleId = result.data['articleId'];

        await Future.delayed(const Duration(seconds: 1));

        // Launch app with NYC metro
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Select NYC metro
        final nycMetroFinder = find.text('New York City');
        if (nycMetroFinder.evaluate().isNotEmpty) {
          await tester.tap(nycMetroFinder);
          await tester.pumpAndSettle();
        } else {
          // Navigate to Settings to change metro
          final settingsTab = find.text('Settings');
          await tester.tap(settingsTab);
          await tester.pumpAndSettle();

          final currentMetro = find.text('Current Metro');
          await tester.tap(currentMetro);
          await tester.pumpAndSettle();

          final nycTile = find.text('New York City');
          await tester.tap(nycTile);
          await tester.pumpAndSettle();

          // Go back to Today
          final todayTab = find.text('Today');
          await tester.tap(todayTab);
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify NYC article appears
        expect(
          find.textContaining('NYC Metro Test: Brooklyn Bridge'),
          findsOneWidget,
          reason: 'NYC article should appear in NYC feed',
        );

        // Switch to SLC metro
        final settingsTab = find.text('Settings');
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        final currentMetro = find.text('Current Metro');
        await tester.tap(currentMetro);
        await tester.pumpAndSettle();

        final slcTile = find.text('Salt Lake City');
        await tester.tap(slcTile);
        await tester.pumpAndSettle();

        final todayTab = find.text('Today');
        await tester.tap(todayTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify NYC article does NOT appear in SLC feed
        expect(
          find.textContaining('NYC Metro Test: Brooklyn Bridge'),
          findsNothing,
          reason: 'NYC article should not appear in SLC feed',
        );

        // Clean up
        await firestore.collection('articles').doc(articleId).delete();
        await firestore.collection('submissions').doc(submissionId).delete();
      },
    );
  });
}
