import 'package:dio/dio.dart';

/// Exception wrapper for network & API errors providing user-friendly messages.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String errorMessage = 'Server responded with status $statusCode.';
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          } else if (data.isNotEmpty) {
            errorMessage = data.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(', ');
          }
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Cannot connect to server. Please ensure the backend is running.',
          originalError: error,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Security certificate verification failed.',
          originalError: error,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
          originalError: error,
        );
    }
  }

  @override
  String toString() => message;
}
