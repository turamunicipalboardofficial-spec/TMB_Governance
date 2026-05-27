import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../models/approve_reject_request.dart';

class FormApprovalDataSource {
  Future<Map<String, dynamic>> getAllForms({
    required int page,
    required int limit,
    required String stage,
    String? search,
    String? status,
    int? formType,
  }) async {
    final body = <String, dynamic>{
      'stage': stage,
      'limit': limit.toString(),
      'page': page.toString(),
      'search': search ?? '',
      'status': status ?? '',
    };
    if (formType != null) body['form_type'] = formType.toString();

    final response = await NetworkService.to.post(
      ApiEndpoints.adminGetAllForms,
      data: body,
    );

    print('Request Body: $body');
    print('Response Data: ${response.data}');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> approveOrReject(
    ApproveRejectRequest request,
  ) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminApproveRejectForm,
      data: request.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getFormStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminFormStats,
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }
}
