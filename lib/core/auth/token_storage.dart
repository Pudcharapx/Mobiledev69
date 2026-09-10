import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage service utilizing `flutter_secure_storage` per SRS 3.2.
class TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _keyAccessToken = 'access_token';
  static const String _keyIdToken = 'id_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyExpiresAt = 'expires_at';

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Save OAuth / OIDC tokens and expiration timestamp to secure storage.
  Future<void> saveTokens({
    required String accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (idToken != null) {
      await _storage.write(key: _keyIdToken, value: idToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
    if (expiresAt != null) {
      await _storage.write(
        key: _keyExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  /// Retrieve the current Bearer access token.
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Retrieve the ID token containing user claims.
  Future<String?> getIdToken() async {
    return _storage.read(key: _keyIdToken);
  }

  /// Retrieve the refresh token if present.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  /// Retrieve the token expiry date.
  Future<DateTime?> getExpiresAt() async {
    final raw = await _storage.read(key: _keyExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Check whether the stored token has expired.
  Future<bool> isTokenExpired() async {
    final expiresAt = await getExpiresAt();
    if (expiresAt == null) return false;
    // Consider expired 30 seconds before exact timestamp to prevent race conditions
    return DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
  }

  /// Check whether a valid, non-empty access token is present.
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.trim().isEmpty) return false;
    final expired = await isTokenExpired();
    return !expired;
  }

  /// Clear all stored tokens completely on logout.
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyIdToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
  }
}
