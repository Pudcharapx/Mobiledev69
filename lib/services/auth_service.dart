import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  static const _userKey = 'dormmate_user_name';
  static const _emailKey = 'dormmate_user_email';

  AuthService({
    required ApiService apiService,
    FlutterSecureStorage? storage,
  })  : _apiService = apiService,
        _storage = storage ?? const FlutterSecureStorage();

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

  Future<void> logout() async {
    await _apiService.clearToken();
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
