import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../models/profile_update_request.dart';
import '../models/change_password_request.dart';

class ProfileDataSource {
  Future<Map<String, dynamic>> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.profileUpdate,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(
    ChangePasswordRequest request,
  ) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.changePassword,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<void> logout() async {
    await NetworkService.to.post(ApiEndpoints.logout);
  }
}
