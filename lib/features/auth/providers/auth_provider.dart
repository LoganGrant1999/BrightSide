import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/auth/models/auth_user.dart';
import 'package:brightside/features/auth/data/auth_repository.dart';
import 'package:brightside/features/metro/metro_provider.dart';

/// Authentication state
enum AuthStatus {
  signedOut,
  signedIn,
  loading,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.signedOut()
      : status = AuthStatus.signedOut,
        user = null,
        error = null;

  const AuthState.signedIn(AuthUser user)
      : status = AuthStatus.signedIn,
        user = user,
        error = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        error = null;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository)
      : super(
          _repository.currentUser != null
              ? AuthState.signedIn(_repository.currentUser!)
              : const AuthState.signedOut(),
        );

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = AuthState.signedIn(user);
      } else {
        state = const AuthState.signedOut();
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.signedOut,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.signInWithApple();
      if (user != null) {
        state = AuthState.signedIn(user);
      } else {
        state = const AuthState.signedOut();
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.signedOut,
        error: e.toString(),
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) {
        state = AuthState.signedIn(user);
      } else {
        state = const AuthState.signedOut();
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.signedOut,
        error: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _repository.signOut();
      state = const AuthState.signedOut();
    } catch (e) {
      // Even on error, sign out locally
      state = const AuthState.signedOut();
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    state = const AuthState.loading();
    try {
      await _repository.deleteAccount();
      state = const AuthState.signedOut();
    } catch (e) {
      state = AuthState(
        status: state.status,
        user: state.user,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockAuthRepository(prefs);
});

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
