import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class PaymentHistoryDataSource {
  /// GET /api/dashboard/admin/payment-history
  Future<dynamic> getAdminPaymentHistory({
    String? status,
    String? formType,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (formType != null && formType.isNotEmpty) queryParams['form_type'] = formType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminPaymentHistory,
      queryParameters: queryParams,
    );
    return response.data;
  }
}
