import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics helper for logging events throughout the app
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log app open event
  /// Called when the app starts
  static Future<void> logAppOpen() async {
    if (kDebugMode) {
      debugPrint('[Analytics] app_open');
    }
    await _analytics.logEvent(name: 'app_open');
  }

  /// Log metro set event
  /// Called when user selects or changes their metro
  static Future<void> logMetroSet(String metroId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] metro_set: $metroId');
    }
    await _analytics.logEvent(
      name: 'metro_set',
      parameters: {
        'metro_id': metroId,
      },
    );
  }

  /// Log article open event
  /// Called when user opens an article/story
  static Future<void> logArticleOpen({
    required String articleId,
    required String metroId,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] article_open: $articleId (metro: $metroId)');
    }
    await _analytics.logEvent(
      name: 'article_open',
      parameters: {
        'article_id': articleId,
        'metro_id': metroId,
      },
    );
  }

  /// Log notification open event
  /// Called when user taps a push notification
  static Future<void> logNotificationOpen(String metroId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] notif_open: $metroId');
    }
    await _analytics.logEvent(
      name: 'notif_open',
      parameters: {
        'metro_id': metroId,
      },
    );
  }

  /// Set user property for metro
  /// Useful for segmentation in Analytics
  static Future<void> setUserMetro(String metroId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] set user property: metro = $metroId');
    }
    await _analytics.setUserProperty(name: 'metro', value: metroId);
  }

  /// Set user ID
  /// Called after successful authentication
  static Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      debugPrint('[Analytics] set user ID: $userId');
    }
    await _analytics.setUserId(id: userId);
  }
}
