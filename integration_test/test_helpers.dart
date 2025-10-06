import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper utilities for integration tests
///
/// Provides common functions for seeding data, cleaning up, and managing test state

class TestHelpers {
  /// Calculate 5am rolling window for article queries
  /// If before 5am today, returns 5am yesterday; otherwise 5am today
  static DateTime calculateFiveAmWindow() {
    final now = DateTime.now();
    final today5am = DateTime(now.year, now.month, now.day, 5, 0, 0);

    if (now.isBefore(today5am)) {
      return today5am.subtract(const Duration(days: 1));
    }
    return today5am;
  }

  /// Seed a test article to Firestore
  static Future<String> seedArticle(
    FirebaseFirestore firestore, {
    required String title,
    required String summary,
    required String metroId,
    String sourceName = 'Test Source',
    String sourceUrl = 'https://example.com/test',
    String? imageUrl,
    DateTime? publishTime,
    String status = 'published',
    bool isFeatured = false,
    int likeCount = 0,
  }) async {
    final windowStart = calculateFiveAmWindow();
    final effectivePublishTime = publishTime ?? windowStart.add(const Duration(hours: 1));

    final article = {
      'title': title,
      'summary': summary,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'image_url': imageUrl ?? 'https://via.placeholder.com/400x300',
      'metro_id': metroId,
      'status': status,
      'publish_time': Timestamp.fromDate(effectivePublishTime),
      'is_featured': isFeatured,
      'featured_start': isFeatured ? FieldValue.serverTimestamp() : null,
      'featured_end': null,
      'like_count': likeCount,
      'like_count_total': likeCount,
      'like_count_24h': likeCount,
      'hot_score': 0,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore.collection('articles').add(article);
    return docRef.id;
  }

  /// Seed a test submission to Firestore
  static Future<String> seedSubmission(
    FirebaseFirestore firestore, {
    required String title,
    required String description,
    required String metroId,
    required String userId,
    String sourceUrl = 'https://example.com/submission',
    String? imageUrl,
    String status = 'pending',
  }) async {
    final submission = {
      'title': title,
      'desc': description,
      'metro_id': metroId,
      'source_url': sourceUrl,
      'image_url': imageUrl,
      'submittedByUid': userId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore.collection('submissions').add(submission);
    return docRef.id;
  }

  /// Clean up test articles by source name
  static Future<void> cleanupArticlesBySource(
    FirebaseFirestore firestore,
    String sourceName,
  ) async {
    final articles = await firestore
        .collection('articles')
        .where('source_name', isEqualTo: sourceName)
        .get();

    for (final doc in articles.docs) {
      await doc.reference.delete();
    }
  }

  /// Clean up test submissions by title pattern
  static Future<void> cleanupSubmissionsByTitle(
    FirebaseFirestore firestore,
    String titlePattern,
  ) async {
    final submissions = await firestore
        .collection('submissions')
        .where('title', isGreaterThanOrEqualTo: titlePattern)
        .where('title', isLessThanOrEqualTo: '$titlePattern\uf8ff')
        .get();

    for (final doc in submissions.docs) {
      await doc.reference.delete();
    }
  }

  /// Create a test user in Auth emulator
  static Future<String> createTestUser(
    FirebaseAuth auth, {
    String? email,
    String password = 'testpassword123',
  }) async {
    final effectiveEmail = email ?? 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: effectiveEmail,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      // User might already exist, try to sign in
      final userCredential = await auth.signInWithEmailAndPassword(
        email: effectiveEmail,
        password: password,
      );
      return userCredential.user!.uid;
    }
  }

  /// Sign in with test user
  static Future<String> signInTestUser(
    FirebaseAuth auth, {
    required String email,
    String password = 'testpassword123',
  }) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user!.uid;
  }

  /// Sign out current user
  static Future<void> signOut(FirebaseAuth auth) async {
    await auth.signOut();
  }

  /// Wait for Firestore to process writes
  static Future<void> waitForFirestore([Duration duration = const Duration(milliseconds: 500)]) async {
    await Future.delayed(duration);
  }

  /// Clean up all test data (use with caution)
  static Future<void> cleanupAllTestData(FirebaseFirestore firestore) async {
    // Clean up articles
    await cleanupArticlesBySource(firestore, 'Integration Test');
    await cleanupArticlesBySource(firestore, 'Window Test');
    await cleanupArticlesBySource(firestore, 'Status Test');
    await cleanupArticlesBySource(firestore, 'Test Source');

    // Clean up submissions
    await cleanupSubmissionsByTitle(firestore, 'Moderation Test:');
    await cleanupSubmissionsByTitle(firestore, 'Rejection Test:');
    await cleanupSubmissionsByTitle(firestore, 'NYC Metro Test:');
    await cleanupSubmissionsByTitle(firestore, 'Test Good News');
  }

  /// Verify article exists with expected data
  static Future<bool> verifyArticleExists(
    FirebaseFirestore firestore, {
    required String articleId,
    String? expectedTitle,
    String? expectedMetro,
    String? expectedStatus,
  }) async {
    final article = await firestore.collection('articles').doc(articleId).get();

    if (!article.exists) return false;

    final data = article.data()!;

    if (expectedTitle != null && data['title'] != expectedTitle) return false;
    if (expectedMetro != null && data['metro_id'] != expectedMetro) return false;
    if (expectedStatus != null && data['status'] != expectedStatus) return false;

    return true;
  }

  /// Verify submission exists with expected status
  static Future<bool> verifySubmissionStatus(
    FirebaseFirestore firestore, {
    required String submissionId,
    required String expectedStatus,
  }) async {
    final submission = await firestore.collection('submissions').doc(submissionId).get();

    if (!submission.exists) return false;

    final data = submission.data()!;
    return data['status'] == expectedStatus;
  }
}

/// Extension to add delay helper to WidgetTester
extension WidgetTesterExtension on WidgetTester {
  /// Pump and settle with a delay
  Future<void> pumpAndSettleWithDelay([Duration delay = const Duration(seconds: 1)]) async {
    await pumpAndSettle();
    await Future.delayed(delay);
    await pumpAndSettle();
  }
}
