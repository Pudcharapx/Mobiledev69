import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/auth/auth_service.dart' as core_auth;
import '../core/auth/oidc_config.dart';
import '../core/auth/token_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final core_auth.AuthService _coreAuth;

  static const _userKey = 'dormmate_user_name';
  static const _emailKey = 'dormmate_user_email';

  AuthService({
    required ApiService apiService,
    FlutterSecureStorage? storage,
    core_auth.AuthService? coreAuth,
  })  : _apiService = apiService,
        _storage = storage ?? const FlutterSecureStorage(),
        _coreAuth = coreAuth ??
            core_auth.AuthService(
              config: OidcConfig.defaultConfig(),
              tokenStorage: TokenStorage(storage: storage),
            );

  Future<bool> login(String username, String password) async {
    try {
      final res = await _apiService.login(username, password);
      if (res is Map<String, dynamic> && res.containsKey('access_token')) {
        final token = res['access_token'] as String;
        await _apiService.saveToken(token);

        final user = res['user'] as Map<String, dynamic>?;
        if (user != null) {
          final fullName = ('${user['first_name']} ${user['last_name']}').trim();
          final display = fullName.isNotEmpty ? fullName : (user['username'] ?? username);
          await _storage.write(key: _userKey, value: display);
          if (user['email'] != null) {
            await _storage.write(key: _emailKey, value: user['email'] as String);
          }
        } else {
          await _storage.write(key: _userKey, value: username);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Initiate OIDC Authorization Code Flow via browser redirect to Django OIDC Server
  Future<void> startOidcLogin() async {
    await _coreAuth.startLogin();
  }

  /// Process callback from OIDC Server upon successful authorization redirect
  Future<bool> handleOidcCallback() async {
    try {
      final session = await _coreAuth.handleCallback();
      if (session != null) {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          await _apiService.saveToken(token);
        }
        final name = session.name;
        final displayName = (name != null && name.isNotEmpty)
            ? name
            : (session.username.isNotEmpty ? session.username : 'Resident');
        await _storage.write(key: _userKey, value: displayName);
        final email = session.email;
        if (email != null && email.isNotEmpty) {
          await _storage.write(key: _emailKey, value: email);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    await _coreAuth.logout();
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _emailKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiService.loadToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getCurrentUserName() async {
    return _storage.read(key: _userKey);
  }

  Future<String?> getCurrentUserEmail() async {
    return _storage.read(key: _emailKey);
  }
}

