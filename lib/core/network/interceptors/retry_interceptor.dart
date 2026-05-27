import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['noRetry'] == true) {
      handler.next(err);
      return;
    }
    final retries = err.requestOptions.extra['retries'] ?? 0;
    if (retries < maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra['retries'] = retries + 1;
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } on DioException catch (e) {
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode == null || err.response!.statusCode! >= 500);
  }
}
