import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Connection timeout', 408);
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      default:
        return ServerFailure(
          error.message ?? 'Unknown error',
          error.response?.statusCode,
        );
    }
  }

  static Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    String message = 'Something went wrong';
    if (data is Map) {
      message = data['message'] ?? data['error'] ?? message;
    }
    if (statusCode == 401) return AuthFailure(message);
    return ServerFailure(message, statusCode);
  }

  static Failure handleException(Object e) {
    if (e is DioException) return handle(e);
    if (e is Failure) return e;
    return ServerFailure(e.toString(), null);
  }
}
