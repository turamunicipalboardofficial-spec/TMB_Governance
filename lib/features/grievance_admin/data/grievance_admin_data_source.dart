import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class GrievanceAdminDataSource {
  /// POST /api/grievances/admin/all
  Future<dynamic> getAllGrievances({
    String? status,
    String? category,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    final data = <String, dynamic>{'per_page': perPage, 'page': page};
    if (status != null && status.isNotEmpty) data['status'] = status;
    if (category != null && category.isNotEmpty) data['category'] = category;
    if (search != null && search.isNotEmpty) data['search'] = search;

    final response = await NetworkService.to.post(
      ApiEndpoints.adminGrievancesAll,
      data: data,
    );
    return response.data;
  }

  /// POST /api/grievances/admin/update-status
  Future<dynamic> updateStatus({
    required String grievanceId,
    required String status,
    String? adminRemarks,
  }) async {
    final data = <String, dynamic>{
      'grievance_id': grievanceId,
      'status': status,
    };
    if (adminRemarks != null && adminRemarks.isNotEmpty) {
      data['admin_remarks'] = adminRemarks;
    }

    final response = await NetworkService.to.post(
      ApiEndpoints.adminUpdateGrievance,
      data: data,
    );
    return response.data;
  }

  /// GET /api/grievances/categories
  Future<dynamic> getCategories() async {
    final response = await NetworkService.to.get(ApiEndpoints.grievanceCategories);
    return response.data;
  }
}
