/// API configuration constants
class ApiConstants {
  ApiConstants._();

  /// Base API URL
  /// TODO: Update this with your actual backend URL
  static const String baseUrl = 'https://api.brightside.local';

  /// API endpoints
  static const String storiesEndpoint = '/stories';
  static const String todayEndpoint = '/stories/today';
  static const String popularEndpoint = '/stories/popular';
  static const String likeEndpoint = '/stories/{id}/like';
  static const String submitEndpoint = '/stories/submit';

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  /// Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}
