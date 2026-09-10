import 'package:dio/dio.dart';
import '../auth/token_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'result.dart';

/// HTTP Client wrapper around `Dio` per SRS 3.3.
class ApiClient {
  final Dio _dio;
  final TokenStorage? _tokenStorage;

  ApiClient({
    String baseUrl = ApiEndpoints.defaultBaseUrl,
    TokenStorage? tokenStorage,
    Dio? customDio,
    void Function()? onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    if (_tokenStorage != null) {
      _dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: _tokenStorage,
          onUnauthorized: onUnauthorized,
        ),
      );
    }
  }

  Dio get dio => _dio;

  /// Perform a GET request and wrap response into [Result].
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Success(response.data as T);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      return Failure(
        apiException.message,
        exception: apiException,
        statusCode: apiException.statusCode,
      );
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  /// Perform a POST request and wrap response into [Result].
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Success(response.data as T);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      return Failure(
        apiException.message,
        exception: apiException,
        statusCode: apiException.statusCode,
      );
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  /// Perform a PUT request and wrap response into [Result].
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Success(response.data as T);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      return Failure(
        apiException.message,
        exception: apiException,
        statusCode: apiException.statusCode,
      );
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  /// Perform a PATCH request and wrap response into [Result].
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Success(response.data as T);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      return Failure(
        apiException.message,
        exception: apiException,
        statusCode: apiException.statusCode,
      );
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  /// Perform a DELETE request and wrap response into [Result].
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Success(response.data as T);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      return Failure(
        apiException.message,
        exception: apiException,
        statusCode: apiException.statusCode,
      );
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }
}
