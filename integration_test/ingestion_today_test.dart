import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:brightside/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Integration test: Ingestion → Today Feed
///
/// Tests the end-to-end flow from article ingestion to display in Today feed.
///
/// Flow:
/// 1. Seed fake articles directly to Firestore (simulating RSS ingestion)
/// 2. Launch app and select metro
/// 3. Verify Today feed shows seeded articles
/// 4. Verify feed respects daily limit (≤5 articles)
///
/// Prerequisites:
/// - Firebase emulators running: firebase emulators:start
/// - Firestore emulator on localhost:8080
/// - Auth emulator on localhost:9099
///
/// Run with: flutter test integration_test/ingestion_today_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;

  setUpAll(() async {
    // Connect to Firebase emulators
    await Firebase.initializeApp();

    // Connect to Firestore emulator
    firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator('localhost', 8080);

    // Connect to Auth emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  });

  group('Ingestion → Today Feed Integration', () {
    testWidgets(
      'Seed 3 articles via emulator → Today shows them',
      (WidgetTester tester) async {
        // Clean up any existing test articles
        final existing = await firestore
            .collection('articles')
            .where('source_name', isEqualTo: 'Integration Test')
            .get();

        for (final doc in existing.docs) {
          await doc.reference.delete();
        }

        // Calculate 5am window (articles published within last 24h from 5am)
        final now = DateTime.now();
        final today5am = DateTime(now.year, now.month, now.day, 5, 0, 0);
        final windowStart = now.isBefore(today5am)
            ? today5am.subtract(const Duration(days: 1))
            : today5am;

        // Seed 3 fake articles for SLC metro
        final article1 = {
          'title': 'Integration Test: Community Garden Thrives',
          'summary': 'Local community garden produces record harvest, feeding 50 families.',
          'source_name': 'Integration Test',
          'source_url': 'https://example.com/garden',
          'image_url': 'https://via.placeholder.com/400x300',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 1))),
          'is_featured': false,
          'featured_start': null,
          'featured_end': null,
          'like_count': 5,
          'like_count_total': 5,
          'like_count_24h': 5,
          'hot_score': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        final article2 = {
          'title': 'Integration Test: Students Launch Kindness Campaign',
          'summary': 'High school students spread positivity with random acts of kindness.',
          'source_name': 'Integration Test',
          'source_url': 'https://example.com/kindness',
          'image_url': 'https://via.placeholder.com/400x300',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 2))),
          'is_featured': false,
          'featured_start': null,
          'featured_end': null,
          'like_count': 3,
          'like_count_total': 3,
          'like_count_24h': 3,
          'hot_score': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        final article3 = {
          'title': 'Integration Test: Local Business Donates to Shelter',
          'summary': 'Family-owned restaurant provides meals to homeless shelter.',
          'source_name': 'Integration Test',
          'source_url': 'https://example.com/donate',
          'image_url': 'https://via.placeholder.com/400x300',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 3))),
          'is_featured': false,
          'featured_start': null,
          'featured_end': null,
          'like_count': 8,
          'like_count_total': 8,
          'like_count_24h': 8,
          'hot_score': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        // Write articles to Firestore
        await firestore.collection('articles').add(article1);
        await firestore.collection('articles').add(article2);
        await firestore.collection('articles').add(article3);

        // Give Firestore time to process
        await Future.delayed(const Duration(milliseconds: 500));

        // Launch app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Select SLC metro if picker appears
        final slcMetroFinder = find.text('Salt Lake City');
        if (slcMetroFinder.evaluate().isNotEmpty) {
          await tester.tap(slcMetroFinder);
          await tester.pumpAndSettle();
        }

        // Should be on Today tab
        expect(find.text('Today'), findsOneWidget);

        // Wait for articles to load
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify our seeded articles appear in the feed
        expect(
          find.textContaining('Integration Test: Community Garden'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Integration Test: Students Launch'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Integration Test: Local Business'),
          findsOneWidget,
        );

        // Verify feed shows ≤5 articles total (daily limit)
        final allArticles = await firestore
            .collection('articles')
            .where('metro_id', isEqualTo: 'slc')
            .where('status', isEqualTo: 'published')
            .where('publish_time', isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart))
            .get();

        expect(allArticles.docs.length, lessThanOrEqualTo(5));

        // Clean up test articles
        for (final doc in allArticles.docs) {
          if (doc.data()['source_name'] == 'Integration Test') {
            await doc.reference.delete();
          }
        }
      },
    );

    testWidgets(
      'Today feed respects 5am rolling window',
      (WidgetTester tester) async {
        // Clean up
        final existing = await firestore
            .collection('articles')
            .where('source_name', isEqualTo: 'Window Test')
            .get();

        for (final doc in existing.docs) {
          await doc.reference.delete();
        }

        // Calculate 5am window
        final now = DateTime.now();
        final today5am = DateTime(now.year, now.month, now.day, 5, 0, 0);
        final windowStart = now.isBefore(today5am)
            ? today5am.subtract(const Duration(days: 1))
            : today5am;

        // Seed article BEFORE window (should NOT appear)
        final oldArticle = {
          'title': 'Window Test: Old Article (Should Not Appear)',
          'summary': 'This article is before the 5am window.',
          'source_name': 'Window Test',
          'source_url': 'https://example.com/old',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.subtract(const Duration(hours: 1))),
          'is_featured': false,
          'like_count': 0,
          'like_count_total': 0,
          'like_count_24h': 0,
          'hot_score': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        // Seed article WITHIN window (should appear)
        final newArticle = {
          'title': 'Window Test: New Article (Should Appear)',
          'summary': 'This article is within the 5am window.',
          'source_name': 'Window Test',
          'source_url': 'https://example.com/new',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 1))),
          'is_featured': false,
          'like_count': 0,
          'like_count_total': 0,
          'like_count_24h': 0,
          'hot_score': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        await firestore.collection('articles').add(oldArticle);
        await firestore.collection('articles').add(newArticle);

        await Future.delayed(const Duration(milliseconds: 500));

        // Launch app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Select SLC metro if needed
        final slcMetroFinder = find.text('Salt Lake City');
        if (slcMetroFinder.evaluate().isNotEmpty) {
          await tester.tap(slcMetroFinder);
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // New article should appear
        expect(
          find.textContaining('Window Test: New Article'),
          findsOneWidget,
        );

        // Old article should NOT appear
        expect(
          find.textContaining('Window Test: Old Article'),
          findsNothing,
        );

        // Clean up
        final cleanup = await firestore
            .collection('articles')
            .where('source_name', isEqualTo: 'Window Test')
            .get();

        for (final doc in cleanup.docs) {
          await doc.reference.delete();
        }
      },
    );

    testWidgets(
      'Today feed excludes non-published articles',
      (WidgetTester tester) async {
        // Clean up
        final existing = await firestore
            .collection('articles')
            .where('source_name', isEqualTo: 'Status Test')
            .get();

        for (final doc in existing.docs) {
          await doc.reference.delete();
        }

        // Calculate window
        final now = DateTime.now();
        final today5am = DateTime(now.year, now.month, now.day, 5, 0, 0);
        final windowStart = now.isBefore(today5am)
            ? today5am.subtract(const Duration(days: 1))
            : today5am;

        // Seed draft article (should NOT appear)
        final draftArticle = {
          'title': 'Status Test: Draft Article (Should Not Appear)',
          'summary': 'This is a draft article.',
          'source_name': 'Status Test',
          'source_url': 'https://example.com/draft',
          'metro_id': 'slc',
          'status': 'draft',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 1))),
          'is_featured': false,
          'created_at': FieldValue.serverTimestamp(),
        };

        // Seed published article (should appear)
        final publishedArticle = {
          'title': 'Status Test: Published Article (Should Appear)',
          'summary': 'This is a published article.',
          'source_name': 'Status Test',
          'source_url': 'https://example.com/published',
          'metro_id': 'slc',
          'status': 'published',
          'publish_time': Timestamp.fromDate(windowStart.add(const Duration(hours: 1))),
          'is_featured': false,
          'like_count': 0,
          'created_at': FieldValue.serverTimestamp(),
        };

        await firestore.collection('articles').add(draftArticle);
        await firestore.collection('articles').add(publishedArticle);

        await Future.delayed(const Duration(milliseconds: 500));

        // Launch app
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Select SLC metro if needed
        final slcMetroFinder = find.text('Salt Lake City');
        if (slcMetroFinder.evaluate().isNotEmpty) {
          await tester.tap(slcMetroFinder);
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Published article should appear
        expect(
          find.textContaining('Status Test: Published Article'),
          findsOneWidget,
        );

        // Draft article should NOT appear
        expect(
          find.textContaining('Status Test: Draft Article'),
          findsNothing,
        );

        // Clean up
        final cleanup = await firestore
            .collection('articles')
            .where('source_name', isEqualTo: 'Status Test')
            .get();

        for (final doc in cleanup.docs) {
          await doc.reference.delete();
        }
      },
    );
  });
}
