import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthDataSource {
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await NetworkService.to.post(ApiEndpoints.logout);
  }
}
