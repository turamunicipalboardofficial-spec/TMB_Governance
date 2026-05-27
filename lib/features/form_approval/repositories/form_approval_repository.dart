import '../../../core/error/error_handler.dart';
import '../../../core/models/paginated_response.dart';
import '../data/form_approval_data_source.dart';
import '../models/form_list_item.dart';
import '../models/approve_reject_request.dart';

class FormApprovalRepository {
  final FormApprovalDataSource _dataSource;

  FormApprovalRepository(this._dataSource);

  Future<PaginatedResponse<FormListItem>> getAllForms({
    required int page,
    required int limit,
    required String stage,
    String? search,
    String? status,
    int? formType,
  }) async {
    try {
      final response = await _dataSource.getAllForms(
        page: page,
        limit: limit,
        stage: stage,
        search: search,
        status: status,
        formType: formType,
      );
      final rawData = response['data'];
      if (rawData is List) {
        // API returns a flat array — wrap into PaginatedResponse
        final items = rawData
            .map((e) => FormListItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse(
          data: items,
          currentPage: page,
          lastPage: page,
          total: items.length,
        );
      }
      final dataMap = rawData as Map<String, dynamic>? ?? response;
      return PaginatedResponse.fromJson(
        dataMap,
        (json) => FormListItem.fromJson(json),
      );
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> approveOrReject(ApproveRejectRequest request) async {
    try {
      await _dataSource.approveOrReject(request);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> getFormStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final response = await _dataSource.getFormStats(dateFrom: dateFrom, dateTo: dateTo);
      return response['data'] as Map<String, dynamic>? ?? response;
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}