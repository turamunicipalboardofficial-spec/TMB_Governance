import 'package:dio/dio.dart';
import '../../../core/error/error_handler.dart';
import '../data/auth_data_source.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      return await _dataSource.login(request);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (e) {
      // Silent fail on logout - clear local data regardless
    }
  }
}
