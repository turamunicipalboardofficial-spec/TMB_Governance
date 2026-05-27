import '../../../core/network/network_service.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../models/admin_dashboard_response.dart';

class DashboardDataSource {
  Future<AdminDashboardResponse> getDashboard() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminDashboard);
    return AdminDashboardResponse.fromJson(response.data['data']);
  }
}
