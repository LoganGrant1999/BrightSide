import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist metro selection
/// - If user is signed in: saves to Firestore /users/{uid}.chosen_metro
/// - If not signed in: saves to SharedPreferences (will backfill on sign-in)
class MetroPersistenceService {
  static const String _keyMetroId = 'chosen_metro';

  // Load metro from local storage
  Future<String?> loadMetroFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyMetroId);
    } catch (e) {
      return null;
    }
  }

  // Save metro to local storage
  Future<void> saveMetroToLocal(String metroId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMetroId, metroId);
    } catch (e) {
      // Silently fail
    }
  }

  // Save metro to Firestore (requires auth)
  // TODO: Implement in Prompt 2 when Firebase Auth is added
  Future<void> saveMetroToFirestore(String uid, String metroId) async {
    // Will implement with Firebase Auth
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .set({'chosen_metro': metroId}, SetOptions(merge: true));
  }

  // Load metro from Firestore (requires auth)
  // TODO: Implement in Prompt 2 when Firebase Auth is added
  Future<String?> loadMetroFromFirestore(String uid) async {
    // Will implement with Firebase Auth
    // final doc = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(uid)
    //     .get();
    // return doc.data()?['chosen_metro'] as String?;
    return null;
  }

  // Backfill: Move local metro to Firestore on sign-in
  // TODO: Implement in Prompt 2 when Firebase Auth is added
  Future<void> backfillMetroOnSignIn(String uid) async {
    final localMetro = await loadMetroFromLocal();
    if (localMetro != null) {
      await saveMetroToFirestore(uid, localMetro);
    }
  }

  // Clear local metro
  Future<void> clearLocalMetro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMetroId);
    } catch (e) {
      // Silently fail
    }
  }
}
