import 'package:dio/dio.dart';
import '../auth/token_storage.dart';

/// Dio interceptor that injects Bearer access token into outgoing requests
/// and monitors 401 Unauthorized responses.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage _tokenStorage;
  final void Function()? _onUnauthorized;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
