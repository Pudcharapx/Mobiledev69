import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  String? _currentUserName;
  String? _currentUserEmail;

  AuthViewModel(this._repository);

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.authenticating;
  String? get errorMessage => _errorMessage;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    final isAuth = await _repository.isAuthenticated();
    if (isAuth) {
      _currentUserName = await _repository.getCurrentUserName();
      _currentUserEmail = await _repository.getCurrentUserEmail();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.login(username, password);
      if (success) {
        _currentUserName = await _repository.getCurrentUserName();
        _currentUserEmail = await _repository.getCurrentUserEmail();
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials. Please try again.';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUserName = null;
    _currentUserEmail = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
