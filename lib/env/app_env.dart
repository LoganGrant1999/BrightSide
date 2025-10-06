/// Application environment configuration
///
/// Determines whether the app is running in development or production mode.
/// Use --dart-define=PROD=true to enable production mode.
///
/// Example:
/// - Development: flutter run -t lib/main_dev.dart
/// - Production: flutter run -t lib/main_prod.dart --dart-define=PROD=true
library;

/// Application environment enum
enum AppEnv {
  /// Development environment with emulators and debug tools
  dev,

  /// Production environment with real Firebase services
  prod,
}

/// Environment configuration class
class Env {
  /// Current environment based on compile-time constant
  static const current = bool.fromEnvironment('PROD', defaultValue: false)
      ? AppEnv.prod
      : AppEnv.dev;

  /// Check if running in production
  static bool get isProd => current == AppEnv.prod;

  /// Check if running in development
  static bool get isDev => current == AppEnv.dev;

  /// Get environment name as string
  static String get name => current.name;

  /// Firebase configuration based on environment
  static FirebaseConfig get firebaseConfig {
    switch (current) {
      case AppEnv.dev:
        return FirebaseConfig.dev;
      case AppEnv.prod:
        return FirebaseConfig.prod;
    }
  }
}

/// Firebase configuration per environment
class FirebaseConfig {
  final bool useEmulators;
  final String? firestoreHost;
  final int? firestorePort;
  final String? authHost;
  final int? authPort;
  final String? functionsHost;
  final int? functionsPort;
  final String? storageHost;
  final int? storagePort;

  const FirebaseConfig({
    this.useEmulators = false,
    this.firestoreHost,
    this.firestorePort,
    this.authHost,
    this.authPort,
    this.functionsHost,
    this.functionsPort,
    this.storageHost,
    this.storagePort,
  });

  /// Development configuration with emulators
  static const dev = FirebaseConfig(
    useEmulators: true,
    firestoreHost: 'localhost',
    firestorePort: 8080,
    authHost: 'localhost',
    authPort: 9099,
    functionsHost: 'localhost',
    functionsPort: 5001,
    storageHost: 'localhost',
    storagePort: 9199,
  );

  /// Production configuration (no emulators)
  static const prod = FirebaseConfig(
    useEmulators: false,
  );
}
