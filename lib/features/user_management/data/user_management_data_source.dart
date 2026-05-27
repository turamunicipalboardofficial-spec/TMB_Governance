import 'package:tmb_governance/core/network/endpoints/api_endpoints.dart';
import 'package:tmb_governance/core/network/network_service.dart';
import 'package:tmb_governance/features/user_management/models/create_consumer_request.dart';
import 'package:tmb_governance/features/user_management/models/create_driver_request.dart';
import 'package:tmb_governance/features/user_management/models/create_employee_request.dart';
import 'package:tmb_governance/features/user_management/models/update_user_request.dart';

class UserManagementDataSource {
  Future<dynamic> createDriver(CreateDriverRequest request) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminCreateDriver,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<dynamic> createEmployee(CreateEmployeeRequest request) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminCreateEmployee,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<dynamic> createConsumer(CreateConsumerRequest request) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminCreateConsumer,
      data: request.toJson(),
    );
    return response.data;
  }

  Future<dynamic> listUsers({
    String? role,
    int? wardId,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (wardId != null) queryParams['ward_id'] = wardId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminListUsers,
      queryParameters: queryParams,
    );
    return response.data;
  }

  Future<dynamic> updateUser(int userId, UpdateUserRequest request) async {
    final response = await NetworkService.to.put(
      ApiEndpoints.adminUpdateUser.replaceAll('{id}', userId.toString()),
      data: request.toJson(),
    );
    return response.data;
  }

  Future<dynamic> toggleUserActive(int userId, bool isActive) async {
    final response = await NetworkService.to.patch(
      ApiEndpoints.adminToggleUserActive.replaceAll('{id}', userId.toString()),
      data: {'is_active': isActive},
    );
    return response.data;
  }
}