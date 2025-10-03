import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Initialize FCM and set up listeners
  Future<void> initialize({
    required String? userId,
    required Function(RemoteMessage) onMessageReceived,
  }) async {
    if (userId == null) return;

    // Request permission
    await requestPermission();

    // Get token
    final token = await getToken();
    if (token != null) {
      await _saveDeviceToken(userId, token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _saveDeviceToken(userId, newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(onMessageReceived);

    // Handle notification taps (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permission
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
    return settings;
  }

  /// Get current permission status
  Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        // Get APNS token first for iOS
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS token not available yet');
          return null;
        }
      }

      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save device token to Firestore
  Future<void> _saveDeviceToken(String userId, String token) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceId = token; // Use token as device ID

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId)
          .set({
        'apns_token': Platform.isIOS ? await _messaging.getAPNSToken() : null,
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'app_version': packageInfo.version,
        'last_seen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Device token saved: $deviceId');
    } catch (e) {
      debugPrint('Error saving device token: $e');
    }
  }

  /// Subscribe to metro topic
  Future<void> subscribeToMetroTopic(String metroId) async {
    try {
      final topic = 'metro_${metroId}_daily';
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from metro topic
  Future<void> unsubscribeFromMetroTopic(String metroId) async {
    try {
      final topic = 'metro_${metroId}_daily';
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');

    // Log analytics event
    _analytics.logEvent(
      name: 'notif_open',
      parameters: {
        'metro_id': message.data['metro_id'] ?? 'unknown',
        'notification_type': message.data['type'] ?? 'daily_digest',
        'message_id': message.messageId ?? 'unknown',
      },
    );

    // TODO: Navigate to appropriate screen based on message.data['route']
    // This will be handled by the app's navigation system
  }

  /// Delete device token (on sign out)
  Future<void> deleteDeviceToken(String userId) async {
    try {
      final token = await getToken();
      if (token != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('devices')
            .doc(token)
            .delete();

        debugPrint('Device token deleted');
      }
    } catch (e) {
      debugPrint('Error deleting device token: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Process notification in background
}
