import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:brightside/features/story/data/story_repository.dart';
import 'package:brightside/features/story/model/article_fs.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/features/submit/model/submission_fs.dart';

class StoryRepositoryFirebase implements StoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  StoryRepositoryFirebase({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  String get userId => _auth.currentUser?.uid ?? '';

  @override
  Future<List<Story>> fetchToday(String metroId) async {
    // Compute 24-hour cutoff
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));

    // Try to get articles from last 24 hours
    var snapshot = await _firestore
        .collection('articles')
        .where('metroId', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .where('publishedAt', isGreaterThanOrEqualTo: cutoff)
        .orderBy('publishedAt', descending: true)
        .limit(5)
        .get();

    // If no results, fallback to latest 5 published articles for this metro
    if (snapshot.docs.isEmpty) {
      snapshot = await _firestore
          .collection('articles')
          .where('metroId', isEqualTo: metroId)
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(5)
          .get();
    }

    return snapshot.docs
        .map((doc) => _articleToStory(ArticleFs.fromJson(doc.data())))
        .toList();
  }

  @override
  Future<List<Story>> fetchPopular(String metroId) async {
    // First, try to get featured articles
    final featuredSnapshot = await _firestore
        .collection('articles')
        .where('metroId', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .where('featured', isEqualTo: true)
        .orderBy('featuredAt', descending: true)
        .limit(5)
        .get();

    final featured = featuredSnapshot.docs
        .map((doc) => _articleToStory(ArticleFs.fromJson(doc.data())))
        .toList();

    // If we have 5 or more featured, return them
    if (featured.length >= 5) {
      return featured;
    }

    // Otherwise, fill with top liked from last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final popularSnapshot = await _firestore
        .collection('articles')
        .where('metroId', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .where('publishedAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .orderBy('publishedAt', descending: true)
        .orderBy('likeCount', descending: true)
        .limit(5 - featured.length)
        .get();

    final popular = popularSnapshot.docs
        .map((doc) => _articleToStory(ArticleFs.fromJson(doc.data())))
        .toList();

    return [...featured, ...popular];
  }

  @override
  Future<Story?> getById(String id) async {
    final doc = await _firestore.collection('articles').doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _articleToStory(ArticleFs.fromJson(doc.data()!));
  }

  @override
  Future<int> like(String storyId, String uid) async {
    try {
      final callable = _functions.httpsCallable('likeArticle');
      final result = await callable.call({'storyId': storyId});
      final map = result.data as Map;
      return (map['likeCount'] as num).toInt();
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'failed-precondition' || e.code == 'FEATURED') {
        throw const LikeBlockedFeaturedException();
      }
      rethrow;
    }
  }

  @override
  Future<void> submitUserStory(Story draft) async {
    String? uploadedImageUrl;

    // Upload image if it's a local file path
    if (draft.imageUrl != null && draft.imageUrl!.isNotEmpty) {
      final file = File(draft.imageUrl!);
      if (await file.exists()) {
        uploadedImageUrl = await _uploadImage(file, draft.id);
      } else {
        uploadedImageUrl = draft.imageUrl;
      }
    }

    final submission = SubmissionFs(
      id: draft.id,
      submittedByUid: userId,
      title: draft.title,
      desc: draft.body ?? '',
      city: '', // Extract from metroId if needed
      state: '', // Extract from metroId if needed
      when: DateTime.now(),
      photoUrl: uploadedImageUrl,
      status: SubmissionStatus.pending,
      createdAt: FieldValue.serverTimestamp() as DateTime,
    );

    await _firestore
        .collection('submissions')
        .doc(draft.id)
        .set(submission.toJson());
  }

  Future<String> _uploadImage(File file, String submissionId) async {
    final uid = userId;
    final ref = _storage.ref().child('submissions/$uid/$submissionId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Story _articleToStory(ArticleFs article) {
    return Story(
      id: article.id,
      metroId: article.metroId,
      type: StoryType.original, // Default to original, could be mapped from article data
      title: article.title,
      subhead: article.snippet,
      body: article.body,
      imageUrl: article.imageUrl,
      sourceName: article.sourceName,
      sourceUrl: article.sourceUrl,
      sourceLinks: const [],
      likesCount: article.likeCount,
      createdAt: article.publishedAt,
      publishedAt: article.publishedAt,
      status: article.status == ArticleStatus.published
          ? StoryStatus.published
          : StoryStatus.queued,
    );
  }
}
