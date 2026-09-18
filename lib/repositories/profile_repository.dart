import '../models/user.dart';
import '../services/api_service.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;

  ProfileRepositoryImpl(this._apiService);

  @override
  Future<User> getProfile() async {
    final data = await _apiService.getProfile();
    return User.fromJson(data as Map<String, dynamic>);
  }
}
