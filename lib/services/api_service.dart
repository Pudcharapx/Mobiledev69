import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'dormmate_access_token';

  static String getDefaultBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  ApiService({Dio? dio, FlutterSecureStorage? storage, String? baseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? getDefaultBaseUrl(),
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            )),
        _storage = storage ?? const FlutterSecureStorage();

  // ─── Token storage ──────────────────────────────────────────────────────────

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> loadToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<Options> _authOptions() async {
    final token = await loadToken();
    if (token == null || token.isEmpty) {
      return Options();
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ─── HTTP primitives ────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    final opts = await _authOptions();
    final resp = await _dio.get(path, options: opts);
    return resp.data;
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool authenticated = true}) async {
    final opts = authenticated ? await _authOptions() : Options();
    final resp = await _dio.post(path, data: body, options: opts);
    return resp.data;
  }

  Future<void> delete(String path) async {
    final opts = await _authOptions();
    await _dio.delete(path, options: opts);
  }

  // ─── DormMate Endpoints ─────────────────────────────────────────────────────

  Future<dynamic> login(String username, String password) =>
      post('/api/dormmate/auth/login/', {'username': username, 'password': password}, authenticated: false);

  Future<dynamic> getProfile() => get('/api/dormmate/profile/');
  Future<dynamic> getRoom() => get('/api/dormmate/rooms/me/');
  Future<dynamic> getDashboard() => get('/api/dormmate/dashboard/');
  Future<dynamic> getExpenses() => get('/api/dormmate/expenses/');
  Future<dynamic> getExpenseDetail(int id) => get('/api/dormmate/expenses/$id/');
  Future<dynamic> getMaintenance() => get('/api/dormmate/maintenance/');
  Future<dynamic> getMaintenanceDetail(int id) => get('/api/dormmate/maintenance/$id/');
  Future<dynamic> createMaintenance(Map<String, dynamic> body) =>
      post('/api/dormmate/maintenance/', body);
  Future<void> deleteMaintenance(int id) => delete('/api/dormmate/maintenance/$id/');
  Future<dynamic> getAnnouncements() => get('/api/dormmate/announcements/');
  Future<dynamic> getAnnouncementDetail(int id) => get('/api/dormmate/announcements/$id/');
}
