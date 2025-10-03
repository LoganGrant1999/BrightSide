import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String authProvider; // 'google', 'apple', 'email'
  final String? displayName;
  final String? chosenMetro;
  final bool notificationOptIn;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.authProvider,
    this.displayName,
    this.chosenMetro,
    this.notificationOptIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String,
      authProvider: data['auth_provider'] as String,
      displayName: data['display_name'] as String?,
      chosenMetro: data['chosen_metro'] as String?,
      notificationOptIn: data['notification_opt_in'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'auth_provider': authProvider,
      'display_name': displayName,
      'chosen_metro': chosenMetro,
      'notification_opt_in': notificationOptIn,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
