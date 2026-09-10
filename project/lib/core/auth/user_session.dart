/// Authenticated user session model derived from OIDC claims.
class UserSession {
  final String userId;
  final String username;
  final String? email;
  final String? name;
  final Map<String, dynamic> rawClaims;

  const UserSession({
    required this.userId,
    required this.username,
    this.email,
    this.name,
    this.rawClaims = const {},
  });

  factory UserSession.fromClaims(Map<String, dynamic> claims) {
    final sub = claims['sub']?.toString() ?? '';
    final preferredUsername = claims['preferred_username']?.toString() ??
        claims['nickname']?.toString() ??
        claims['username']?.toString() ??
        claims['name']?.toString() ??
        sub;
    final email = claims['email']?.toString();
    final name = claims['name']?.toString();

    return UserSession(
      userId: sub,
      username: preferredUsername,
      email: email,
      name: name,
      rawClaims: claims,
    );
  }

  @override
  String toString() =>
      'UserSession(userId: $userId, username: $username, email: $email)';
}
