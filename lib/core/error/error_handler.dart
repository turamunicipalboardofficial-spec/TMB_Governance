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

      // Laravel validation errors (422) come back as:
      // { "message": "Validation failed.", "errors": { "field": ["msg1", "msg2"] } }
      // Surface the first concrete error message instead of the generic
      // top-level "Validation failed." text so the UI shows something useful.
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          message = firstValue.first.toString();
        } else if (firstValue is String) {
          message = firstValue;
        }
      }
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
