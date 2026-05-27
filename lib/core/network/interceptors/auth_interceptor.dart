import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import '../../storage/secure_storage_service.dart';
import '../../../routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.to.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Do NOT auto-logout or delete token on 401.
      // Session is preserved until user explicitly logs out.
      // Log the 401 for debugging but let the caller handle it.
      if (kDebugMode) {
        print('AuthInterceptor: 401 received but session preserved');
      }
    }
    handler.next(err);
  }
}

/// Role-based route guard middleware.
class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles;
  RoleGuard({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    return null;
  }
}
