import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/profile_repository.dart';
import '../repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepo;
  final AuthRepository _authRepo;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  ProfileViewModel({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  })  : _profileRepo = profileRepository,
        _authRepo = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileRepo.getProfile();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
  }
}
