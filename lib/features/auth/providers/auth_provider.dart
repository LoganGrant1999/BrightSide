import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';
import '../../onboarding/data/metro_persistence_service.dart';

// Auth state
class AuthState {
  final firebase_auth.User? firebaseUser;
  final AppUser? appUser;
  final bool isLoading;
  final String? error;

  AuthState({
    this.firebaseUser,
    this.appUser,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => firebaseUser != null;

  AuthState copyWith({
    firebase_auth.User? firebaseUser,
    AppUser? appUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      appUser: appUser ?? this.appUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final firebase_auth.FirebaseAuth _auth;
  final UserService _userService;
  final MetroPersistenceService _metroService;

  AuthNotifier({
    firebase_auth.FirebaseAuth? auth,
    UserService? userService,
    MetroPersistenceService? metroService,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _userService = userService ?? UserService(),
        _metroService = metroService ?? MetroPersistenceService(),
        super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        final appUser = await _userService.getUserById(firebaseUser.uid);
        state = AuthState(firebaseUser: firebaseUser, appUser: appUser);
      } else {
        state = AuthState();
      }
    });
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _signInWithCredential(credential, 'google', googleUser.displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      await _handleAuthException(e);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      String? displayName;
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
      }

      await _signInWithCredential(oauthCredential, 'apple', displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      await _handleAuthException(e);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Sign in with email/password
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _handleSuccessfulAuth(
          credential.user!, 'email', credential.user!.displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Create account with email/password
  Future<void> createAccountWithEmail(String email, String password,
      {String? displayName}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      await _handleSuccessfulAuth(credential.user!, 'email', displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getAuthErrorMessage(e));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Helper: Sign in with credential
  Future<void> _signInWithCredential(
    firebase_auth.AuthCredential credential,
    String provider,
    String? displayName,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSuccessfulAuth(userCredential.user!, provider, displayName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // Attempt account linking
        await _linkAccount(credential, e.email!);
      } else {
        rethrow;
      }
    }
  }

  // Helper: Handle successful authentication
  Future<void> _handleSuccessfulAuth(
    firebase_auth.User firebaseUser,
    String provider,
    String? displayName,
  ) async {
    // Get local metro if exists
    final localMetro = await _metroService.loadMetroFromLocal();

    // Create or update user doc
    final appUser = await _userService.upsertUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      authProvider: provider,
      displayName: displayName,
      chosenMetro: localMetro,
    );

    // Clear local metro since it's now in Firestore
    if (localMetro != null) {
      await _metroService.clearLocalMetro();
    }

    state = state.copyWith(
      firebaseUser: firebaseUser,
      appUser: appUser,
      isLoading: false,
    );
  }

  // Helper: Link accounts
  Future<void> _linkAccount(
      firebase_auth.AuthCredential credential, String email) async {
    try {
      state = state.copyWith(
        isLoading: false,
        error:
            'An account already exists with this email ($email). Please sign in with your existing provider first.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Helper: Handle auth exceptions
  Future<void> _handleAuthException(
      firebase_auth.FirebaseAuthException e) async {
    if (e.code == 'account-exists-with-different-credential' &&
        e.email != null) {
      state = state.copyWith(
        isLoading: false,
        error:
            'An account already exists with ${e.email}. Please sign in with your existing provider.',
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e),
      );
    }
  }

  // Helper: Get user-friendly error messages
  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
