import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// System configuration loaded from Firestore /system/config
///
/// Centralizes app-wide settings like legal URLs, feature flags, and limits
class SystemConfig {
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String supportEmail;
  final int todayMaxArticles;
  final bool maintenanceMode;

  const SystemConfig({
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.supportEmail,
    required this.todayMaxArticles,
    required this.maintenanceMode,
  });

  /// Default configuration (fallback if Firestore unavailable)
  static const defaultConfig = SystemConfig(
    privacyPolicyUrl: 'https://brightside-9a2c5.web.app/privacy',
    termsOfServiceUrl: 'https://brightside-9a2c5.web.app/terms',
    supportEmail: 'support@brightside.com',
    todayMaxArticles: 5,
    maintenanceMode: false,
  );

  /// Load configuration from Firestore
  static Future<SystemConfig> load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system')
          .doc('config')
          .get();

      if (!doc.exists) {
        debugPrint('⚙️ System config not found, using defaults');
        return defaultConfig;
      }

      final data = doc.data()!;

      return SystemConfig(
        privacyPolicyUrl: data['privacy_policy_url'] as String? ??
            defaultConfig.privacyPolicyUrl,
        termsOfServiceUrl: data['terms_of_service_url'] as String? ??
            defaultConfig.termsOfServiceUrl,
        supportEmail:
            data['support_email'] as String? ?? defaultConfig.supportEmail,
        todayMaxArticles:
            data['today_max_articles'] as int? ?? defaultConfig.todayMaxArticles,
        maintenanceMode:
            data['maintenance_mode'] as bool? ?? defaultConfig.maintenanceMode,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to load system config: $e');
      return defaultConfig;
    }
  }

  /// Create example config document structure
  static Map<String, dynamic> toFirestoreExample() {
    return {
      'privacy_policy_url': 'https://brightside-9a2c5.web.app/privacy',
      'terms_of_service_url': 'https://brightside-9a2c5.web.app/terms',
      'support_email': 'support@brightside.com',
      'today_max_articles': 5,
      'maintenance_mode': false,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
