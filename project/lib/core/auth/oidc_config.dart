/// OIDC Client configuration per SRS 3.2 and Task 2.
class OidcConfig {
  final Uri issuerUri;
  final String clientId;
  final List<String> scopes;
  final Uri redirectUri;
  final Uri postLogoutRedirectUri;

  const OidcConfig({
    required this.issuerUri,
    required this.clientId,
    required this.scopes,
    required this.redirectUri,
    required this.postLogoutRedirectUri,
  });

  /// Default configuration matching the Django backend OIDC provider.
  factory OidcConfig.defaultConfig() {
    return OidcConfig(
      issuerUri: Uri.parse('http://127.0.0.1:8000'),
      clientId: 'muscledev-frontend',
      scopes: const ['openid', 'profile', 'email'],
      redirectUri: Uri.parse('http://localhost:50000/callback'),
      postLogoutRedirectUri: Uri.parse('http://localhost:50000'),
    );
  }
}
