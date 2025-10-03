import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection names
class Collections {
  static const String articles = 'articles';
  static const String submissions = 'submissions';
  static const String users = 'users';
  static const String articleLikes = 'articleLikes';
  static const String reports = 'reports';
  static const String metros = 'metros';
  static const String system = 'system';
}

/// Query builders for BrightSide app
class BrightSideQueries {
  /// Get today's stories for a specific metro
  /// Returns ≤ 5 most recent published articles
  static Query<Map<String, dynamic>> todayQuery(
    FirebaseFirestore firestore,
    String metroId,
  ) {
    return firestore
        .collection(Collections.articles)
        .where('metro_id', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .orderBy('publish_time', descending: true)
        .limit(5);
  }

  /// Get popular stories for a specific metro
  /// Sorted by 24h like count, then publish time
  /// Returns ≤ 10 articles
  static Query<Map<String, dynamic>> popularQuery(
    FirebaseFirestore firestore,
    String metroId,
  ) {
    return firestore
        .collection(Collections.articles)
        .where('metro_id', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .orderBy('like_count_24h', descending: true)
        .orderBy('publish_time', descending: true)
        .limit(10);
  }

  /// Get featured stories for a specific metro
  /// Returns ≤ 5 currently featured articles
  static Query<Map<String, dynamic>> featuredQuery(
    FirebaseFirestore firestore,
    String metroId,
  ) {
    return firestore
        .collection(Collections.articles)
        .where('metro_id', isEqualTo: metroId)
        .where('status', isEqualTo: 'published')
        .where('is_featured', isEqualTo: true)
        .orderBy('featured_start', descending: true)
        .limit(5);
  }

  /// Get a user's likes for a specific article
  /// Used to check if user has already liked an article
  static Query<Map<String, dynamic>> userLikeQuery(
    FirebaseFirestore firestore,
    String userId,
    String articleId,
  ) {
    return firestore
        .collection(Collections.articleLikes)
        .where('user_id', isEqualTo: userId)
        .where('article_id', isEqualTo: articleId)
        .limit(1);
  }

  /// Get all likes by a user in a specific metro
  static Query<Map<String, dynamic>> userLikesInMetroQuery(
    FirebaseFirestore firestore,
    String userId,
    String metroId,
  ) {
    return firestore
        .collection(Collections.articleLikes)
        .where('user_id', isEqualTo: userId)
        .where('metro_id', isEqualTo: metroId)
        .orderBy('created_at', descending: true);
  }

  /// Get user's own submissions
  static Query<Map<String, dynamic>> userSubmissionsQuery(
    FirebaseFirestore firestore,
    String userId,
  ) {
    return firestore
        .collection(Collections.submissions)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true);
  }

  /// Get all active metros
  static Query<Map<String, dynamic>> activeMetrosQuery(
    FirebaseFirestore firestore,
  ) {
    return firestore
        .collection(Collections.metros)
        .where('active', isEqualTo: true);
  }

  /// Get system configuration
  static DocumentReference<Map<String, dynamic>> systemConfigRef(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection(Collections.system).doc('config');
  }
}

/// Field names for Firestore documents
class ArticleFields {
  static const String title = 'title';
  static const String summary = 'summary';
  static const String sourceName = 'source_name';
  static const String sourceUrl = 'source_url';
  static const String imageUrl = 'image_url';
  static const String metroId = 'metro_id';
  static const String status = 'status';
  static const String publishTime = 'publish_time';
  static const String isFeatured = 'is_featured';
  static const String featuredStart = 'featured_start';
  static const String featuredEnd = 'featured_end';
  static const String likeCountTotal = 'like_count_total';
  static const String likeCount24h = 'like_count_24h';
  static const String hotScore = 'hot_score';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class SubmissionFields {
  static const String userId = 'user_id';
  static const String metroId = 'metro_id';
  static const String title = 'title';
  static const String summary = 'summary';
  static const String sourceName = 'source_name';
  static const String sourceUrl = 'source_url';
  static const String imageUrl = 'image_url';
  static const String status = 'status';
  static const String moderatorId = 'moderator_id';
  static const String moderatorNote = 'moderator_note';
  static const String approvedArticleId = 'approved_article_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class UserFields {
  static const String email = 'email';
  static const String authProvider = 'auth_provider';
  static const String displayName = 'display_name';
  static const String chosenMetro = 'chosen_metro';
  static const String notificationOptIn = 'notification_opt_in';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String deletedAt = 'deleted_at';
}

class LikeFields {
  static const String userId = 'user_id';
  static const String articleId = 'article_id';
  static const String metroId = 'metro_id';
  static const String createdAt = 'created_at';
}

class ReportFields {
  static const String userId = 'user_id';
  static const String articleId = 'article_id';
  static const String metroId = 'metro_id';
  static const String reason = 'reason';
  static const String details = 'details';
  static const String triageStatus = 'triage_status';
  static const String moderatorId = 'moderator_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Status values
class ArticleStatus {
  static const String published = 'published';
  static const String archived = 'archived';
}

class SubmissionStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class ReportReason {
  static const String spam = 'spam';
  static const String offensive = 'offensive';
  static const String misinfo = 'misinfo';
  static const String other = 'other';
}

class TriageStatus {
  static const String newStatus = 'new';
  static const String reviewing = 'reviewing';
  static const String closed = 'closed';
}

class AuthProvider {
  static const String anonymous = 'anonymous';
  static const String google = 'google';
  static const String apple = 'apple';
  static const String password = 'password';
}
