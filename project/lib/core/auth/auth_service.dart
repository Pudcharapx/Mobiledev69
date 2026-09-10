import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:openid_client/openid_client.dart';
import 'oidc_config.dart';
import 'oidc_platform/oidc_authenticator.dart' as platform_auth;
import 'token_storage.dart';
import 'user_session.dart';

/// Authentication Service managing OIDC flows via `openid_client`
/// and persistent token storage via `TokenStorage` per SRS 3.2.
class AuthService extends ChangeNotifier {
  final OidcConfig _config;
  final TokenStorage _tokenStorage;

  Client? _oidcClient;
  UserSession? _currentUser;
  bool _initialized = false;

  AuthService({
    OidcConfig? config,
    TokenStorage? tokenStorage,
  })  : _config = config ?? OidcConfig.defaultConfig(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  OidcConfig get config => _config;
  TokenStorage get tokenStorage => _tokenStorage;
  UserSession? get currentUser => _currentUser;
  bool get isInitialized => _initialized;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth state from persisted storage on app launch.
  Future<void> initialize() async {
    if (_initialized) return;

    final hasToken = await _tokenStorage.hasValidToken();
    if (hasToken) {
      final idToken = await _tokenStorage.getIdToken();
      if (idToken != null) {
        _currentUser = _parseSessionFromJwt(idToken);
      }
    } else {
      // If no stored token, check if we just landed on a callback from OIDC redirect
      try {
        await handleCallback();
      } catch (_) {
        // Ignored if not on a callback URL
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Get the OIDC Client instance via dynamic discovery.
  Future<Client> getClient() async {
    if (_oidcClient != null) return _oidcClient!;
    final issuer = await Issuer.discover(_config.issuerUri);
    _oidcClient = Client(issuer, _config.clientId);
    return _oidcClient!;
  }

  /// Start OIDC Authorization Code Flow + PKCE redirect.
  Future<void> startLogin() async {
    final client = await getClient();
    platform_auth.authorizeBrowser(client, _config.scopes);
  }

  /// Handle callback on redirect URL, retrieve token credential, and save to storage.
  Future<UserSession?> handleCallback() async {
    try {
      final client = await getClient();
      final credential =
          await platform_auth.authenticateBrowser(client, _config.scopes);
      if (credential == null) return null;

      final tokenResponse = await credential.getTokenResponse();
      final accessToken = tokenResponse.accessToken;
      final idToken = tokenResponse.idToken.toCompactSerialization();
      final refreshToken = tokenResponse.refreshToken;
      final expiresAt = tokenResponse.expiresAt;

      if (accessToken != null) {
        await _tokenStorage.saveTokens(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        final claims = credential.idToken.claims.toJson();
        _currentUser = UserSession.fromClaims(claims);
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Error handling OIDC callback: $e');
    }
    return null;
  }

  /// Clear tokens and log out completely.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    _currentUser = null;
    notifyListeners();
  }

  /// Decode JWT payload to parse user session claims.
  UserSession? _parseSessionFromJwt(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decodedJson = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> claims = jsonDecode(decodedJson);
      return UserSession.fromClaims(claims);
    } catch (_) {
      return null;
    }
  }
}
