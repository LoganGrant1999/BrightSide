import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/firebase_options.dart';

/// Initialize Firebase and ensure anonymous authentication
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  if (!kDebugMode) {
    // Enable Crashlytics only in release mode
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Set Crashlytics collection enabled
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  final currentUser = FirebaseAuth.instance.currentUser;

  // Sign in anonymously if no user or user is not anonymous
  if (currentUser == null || !currentUser.isAnonymous) {
    await FirebaseAuth.instance.signInAnonymously();
  }
}

/// Provider that exposes the current Firebase user's UID (stream)
final uidProvider = StreamProvider<String?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) => user?.uid);
});

/// Provider that exposes the current Firebase user's UID (synchronous)
/// Returns null if not yet authenticated
final userUidProvider = Provider<String?>((ref) {
  final asyncValue = ref.watch(uidProvider);
  return asyncValue.valueOrNull;
});
