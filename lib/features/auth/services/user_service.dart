import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  UserService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  /// Get user by ID
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Create or update user document
  Future<AppUser> upsertUser({
    required String uid,
    required String email,
    required String authProvider,
    String? displayName,
    String? chosenMetro,
  }) async {
    final now = DateTime.now();
    final userRef = _firestore.collection('users').doc(uid);

    // Check if user exists
    final existingDoc = await userRef.get();

    if (existingDoc.exists) {
      // Update existing user
      final updates = <String, dynamic>{
        'updated_at': Timestamp.fromDate(now),
      };

      // Update display name if provided and different
      if (displayName != null) {
        updates['display_name'] = displayName;
      }

      // Update chosen_metro if provided
      if (chosenMetro != null) {
        updates['chosen_metro'] = chosenMetro;
      }

      await userRef.update(updates);

      final updatedDoc = await userRef.get();
      return AppUser.fromFirestore(updatedDoc);
    } else {
      // Create new user
      final newUser = AppUser(
        uid: uid,
        email: email,
        authProvider: authProvider,
        displayName: displayName,
        chosenMetro: chosenMetro,
        notificationOptIn: false,
        createdAt: now,
        updatedAt: now,
      );

      await userRef.set(newUser.toFirestore());
      return newUser;
    }
  }

  /// Update user's metro
  Future<void> updateMetro(String uid, String metroId) async {
    await _firestore.collection('users').doc(uid).update({
      'chosen_metro': metroId,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Update notification opt-in
  Future<void> updateNotificationOptIn(String uid, bool optIn) async {
    await _firestore.collection('users').doc(uid).update({
      'notification_opt_in': optIn,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete user document
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Delete user account and all associated data
  /// Calls Cloud Function to purge all user data including:
  /// - Auth record
  /// - User document
  /// - Devices subcollection
  /// - Article likes
  /// - Submissions
  /// - Analytics (redacted)
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Call the Cloud Function
      final callable = _functions.httpsCallable('deleteAccount');
      final result = await callable.call<Map<String, dynamic>>({});

      // Check for success
      if (result.data['success'] != true) {
        throw Exception(
          result.data['message'] ?? 'Failed to delete account',
        );
      }
    } on FirebaseFunctionsException catch (e) {
      // Handle Firebase Functions errors
      throw Exception('Delete account error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
