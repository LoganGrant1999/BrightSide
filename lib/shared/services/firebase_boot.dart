import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/firebase_options.dart';
import 'package:brightside/env/app_env.dart';

/// Initialize Firebase and ensure anonymous authentication
/// Connects to emulators in dev mode, production services in prod mode
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulators in development mode only
  final config = Env.firebaseConfig;
  if (config.useEmulators) {
    debugPrint('🔧 Connecting to Firebase emulators...');

    // Firestore emulator
    if (config.firestoreHost != null && config.firestorePort != null) {
      FirebaseFirestore.instance.useFirestoreEmulator(
        config.firestoreHost!,
        config.firestorePort!,
      );
      debugPrint('  ✓ Firestore: ${config.firestoreHost}:${config.firestorePort}');
    }

    // Auth emulator
    if (config.authHost != null && config.authPort != null) {
      await FirebaseAuth.instance.useAuthEmulator(
        config.authHost!,
        config.authPort!,
      );
      debugPrint('  ✓ Auth: ${config.authHost}:${config.authPort}');
    }

    // Functions emulator
    if (config.functionsHost != null && config.functionsPort != null) {
      FirebaseFunctions.instance.useFunctionsEmulator(
        config.functionsHost!,
        config.functionsPort!,
      );
      debugPrint('  ✓ Functions: ${config.functionsHost}:${config.functionsPort}');
    }

    // Storage emulator
    if (config.storageHost != null && config.storagePort != null) {
      await FirebaseStorage.instance.useStorageEmulator(
        config.storageHost!,
        config.storagePort!,
      );
      debugPrint('  ✓ Storage: ${config.storageHost}:${config.storagePort}');
    }

    debugPrint('🔧 Emulators connected');
  } else {
    debugPrint('🚀 Using production Firebase services');
  }

  // Initialize Crashlytics (production only)
  if (!kDebugMode && Env.isProd) {
    // Enable Crashlytics only in release mode and production
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    debugPrint('🛡️ Crashlytics enabled');
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    debugPrint('🛡️ Crashlytics disabled (dev mode)');
  }

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
