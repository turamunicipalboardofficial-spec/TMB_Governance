import 'package:tmb_governance/features/user_management/data/user_management_data_source.dart';
import 'package:tmb_governance/features/user_management/models/create_consumer_request.dart';
import 'package:tmb_governance/features/user_management/models/create_driver_request.dart';
import 'package:tmb_governance/features/user_management/models/create_employee_request.dart';
import 'package:tmb_governance/features/user_management/models/update_user_request.dart';
import 'package:tmb_governance/features/user_management/models/user_model.dart';

class UserManagementRepository {
  final UserManagementDataSource _dataSource;

  UserManagementRepository(this._dataSource);

  Future<void> createDriver(CreateDriverRequest request) async {
    await _dataSource.createDriver(request);
  }

  Future<void> createEmployee(CreateEmployeeRequest request) async {
    await _dataSource.createEmployee(request);
  }

  Future<void> createConsumer(CreateConsumerRequest request) async {
    await _dataSource.createConsumer(request);
  }

  Future<Map<String, dynamic>> listUsers({
    String? role,
    int? wardId,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    final data = await _dataSource.listUsers(
      role: role,
      wardId: wardId,
      search: search,
      perPage: perPage,
      page: page,
    );
    // Response: {status, actor_role, visible_roles, data: {current_page, last_page, total, per_page, data: [...]}}
    final innerData = data['data'] as Map<String, dynamic>? ?? {};
    final rawList = innerData['data'] as List? ?? [];
    final users = rawList
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'users': users,
      'currentPage': innerData['current_page'] ?? 1,
      'lastPage': innerData['last_page'] ?? 1,
      'total': innerData['total'] ?? users.length,
      'perPage': innerData['per_page'] ?? perPage,
    };
  }

  Future<void> updateUser(int userId, UpdateUserRequest request) async {
    await _dataSource.updateUser(userId, request);
  }

  Future<void> toggleUserActive(int userId, bool isActive) async {
    await _dataSource.toggleUserActive(userId, isActive);
  }
}