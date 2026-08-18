import '../../../core/error/error_handler.dart';
import '../../../core/models/paginated_response.dart';
import '../data/form_approval_data_source.dart';
import '../models/form_list_item.dart';
import '../models/form_type.dart';
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
        final items = rawData
            .map((e) => FormListItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return PaginatedResponse(
          data: items,
          currentPage: page,
          lastPage: page,   // not used; controller relies on hasMore flag
          total: items.length,
        );
      }
      // API returns a paginated envelope with current_page / last_page
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

  Future<List<FormType>> getFormTypes() async {
    try {
      final response = await _dataSource.getFormTypes();
      final list = response['forms_list'] as List? ?? [];
      return list
          .map((e) => FormType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}