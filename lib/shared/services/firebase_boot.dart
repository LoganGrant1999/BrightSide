import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/firebase_options.dart';

/// Initialize Firebase and ensure anonymous authentication
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
