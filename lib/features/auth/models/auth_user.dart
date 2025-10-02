/// Authenticated user model
class AuthUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final AuthProvider provider;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AuthUser(id: $id, email: $email, provider: $provider)';
}

/// Authentication provider type
enum AuthProvider {
  google,
  apple,
  email,
  anonymous,
}
