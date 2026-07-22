import '../../../core/error/error_handler.dart';
import '../data/grievance_admin_data_source.dart';
import '../models/grievance_model.dart';

class GrievanceListResult {
  final List<GrievanceModel> grievances;
  final int currentPage;
  final int totalPages;
  final int total;
  final GrievanceSummary summary;

  GrievanceListResult({
    required this.grievances,
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.summary,
  });
}

class GrievanceAdminRepository {
  final GrievanceAdminDataSource _dataSource;

  GrievanceAdminRepository(this._dataSource);

  Future<GrievanceListResult> getAllGrievances({
    String? status,
    String? category,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await _dataSource.getAllGrievances(
        status: status,
        category: category,
        search: search,
        perPage: perPage,
        page: page,
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final grievancesJson = data['grievances'] as List? ?? [];

      return GrievanceListResult(
        grievances: grievancesJson
            .map((e) => GrievanceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        currentPage: data['current_page'] ?? 1,
        totalPages: data['total_pages'] ?? 1,
        total: data['total'] ?? 0,
        summary: GrievanceSummary.fromJson(data['summary'] as Map<String, dynamic>?),
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<GrievanceModel> updateStatus({
    required String grievanceId,
    required String status,
    String? adminRemarks,
  }) async {
    try {
      final response = await _dataSource.updateStatus(
        grievanceId: grievanceId,
        status: status,
        adminRemarks: adminRemarks,
      );
      return GrievanceModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _dataSource.getCategories();
      final data = response['data'] as List? ?? [];
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
