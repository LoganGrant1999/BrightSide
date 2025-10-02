import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/auth/models/auth_user.dart';

/// Abstract authentication repository interface
abstract class AuthRepository {
  /// Get current authenticated user
  AuthUser? get currentUser;

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges;

  /// Sign in with Google
  Future<AuthUser?> signInWithGoogle();

  /// Sign in with Apple
  Future<AuthUser?> signInWithApple();

  /// Sign in with email and password
  Future<AuthUser?> signInWithEmail(String email, String password);

  /// Sign out current user
  Future<void> signOut();

  /// Delete current user account
  Future<void> deleteAccount();
}

/// Mock authentication repository for development
class MockAuthRepository implements AuthRepository {
  static const String _userIdKey = 'mock_auth_user_id';
  static const String _userEmailKey = 'mock_auth_user_email';
  static const String _userNameKey = 'mock_auth_user_name';
  static const String _userProviderKey = 'mock_auth_user_provider';

  final SharedPreferences _prefs;
  AuthUser? _currentUser;

  MockAuthRepository(this._prefs) {
    _loadUser();
  }

  void _loadUser() {
    final userId = _prefs.getString(_userIdKey);
    if (userId != null) {
      final email = _prefs.getString(_userEmailKey);
      final name = _prefs.getString(_userNameKey);
      final providerStr = _prefs.getString(_userProviderKey) ?? 'anonymous';
      final provider = AuthProvider.values.firstWhere(
        (p) => p.name == providerStr,
        orElse: () => AuthProvider.anonymous,
      );

      _currentUser = AuthUser(
        id: userId,
        email: email,
        displayName: name,
        provider: provider,
      );
    }
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create mock user
    final user = AuthUser(
      id: 'mock_google_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      displayName: 'Google User',
      provider: AuthProvider.google,
    );

    await _saveUser(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Create mock user
    final user = AuthUser(
      id: 'mock_apple_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@privaterelay.appleid.com',
      displayName: 'Apple User',
      provider: AuthProvider.apple,
    );

    await _saveUser(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Basic validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Create mock user
    final user = AuthUser(
      id: 'mock_email_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      provider: AuthProvider.email,
    );

    await _saveUser(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Clear user data
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userProviderKey);

    _currentUser = null;
  }

  @override
  Future<void> deleteAccount() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // For mock, just sign out and clear all local data
    await _prefs.clear();
    _currentUser = null;
  }

  Future<void> _saveUser(AuthUser user) async {
    await _prefs.setString(_userIdKey, user.id);
    if (user.email != null) {
      await _prefs.setString(_userEmailKey, user.email!);
    }
    if (user.displayName != null) {
      await _prefs.setString(_userNameKey, user.displayName!);
    }
    await _prefs.setString(_userProviderKey, user.provider.name);
  }
}
