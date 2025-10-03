/// Application environment configuration
enum Environment {
  development,
  staging,
  production;

  /// Current active environment
  /// Change this to switch between environments
  static const Environment current = Environment.development;

  /// Whether to use Firebase repositories
  static bool get useFirebase {
    const env = String.fromEnvironment('BRIGHTSIDE_USE_FIREBASE', defaultValue: 'false');
    return env.toLowerCase() == 'true';
  }

  /// Whether to use mock repositories
  bool get useMockRepositories {
    // If Firebase is enabled, don't use mocks
    if (useFirebase) return false;

    return switch (this) {
      Environment.development => true,
      Environment.staging => false,
      Environment.production => false,
    };
  }

  /// Environment name for debugging
  String get name {
    return switch (this) {
      Environment.development => 'Development',
      Environment.staging => 'Staging',
      Environment.production => 'Production',
    };
  }
}
