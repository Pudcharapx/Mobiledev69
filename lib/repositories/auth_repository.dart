import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<bool> login(String username, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getCurrentUserName();
  Future<String?> getCurrentUserEmail();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<bool> login(String username, String password) =>
      _authService.login(username, password);

  @override
  Future<void> logout() => _authService.logout();

  @override
  Future<bool> isAuthenticated() => _authService.isAuthenticated();

  @override
  Future<String?> getCurrentUserName() => _authService.getCurrentUserName();

  @override
  Future<String?> getCurrentUserEmail() => _authService.getCurrentUserEmail();
}
