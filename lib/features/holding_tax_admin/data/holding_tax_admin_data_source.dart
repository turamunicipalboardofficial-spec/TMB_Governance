import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class HoldingTaxAdminDataSource {
  /// POST /api/holding-taxes/search
  Future<dynamic> search({String? query, String? type}) async {
    final data = <String, dynamic>{};
    if (query != null && query.isNotEmpty) data['q'] = query;
    if (type != null && type.isNotEmpty) data['type'] = type;

    final response = await NetworkService.to.post(
      ApiEndpoints.holdingTaxSearch,
      data: data,
    );
    return response.data;
  }

  /// POST /api/holding-taxes/details
  Future<dynamic> getDetails(String holdingNo) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.holdingTaxDetails,
      data: {'holding_no': holdingNo},
    );
    return response.data;
  }

  /// POST /api/holding-taxes/pay
  Future<dynamic> pay({
    required String holdingNo,
    double? paidAmount,
    String? paymentRemarks,
  }) async {
    final data = <String, dynamic>{'holding_no': holdingNo};
    if (paidAmount != null) data['paid_amount'] = paidAmount;
    if (paymentRemarks != null && paymentRemarks.isNotEmpty) {
      data['payment_remarks'] = paymentRemarks;
    }

    final response = await NetworkService.to.post(
      ApiEndpoints.holdingTaxPay,
      data: data,
    );
    return response.data;
  }

  /// GET /api/holding-taxes/stats
  Future<dynamic> getStats({String? type}) async {
    final response = await NetworkService.to.get(
      ApiEndpoints.adminHoldingTaxStats,
      queryParameters: type != null && type.isNotEmpty ? {'type': type} : null,
    );
    return response.data;
  }

  /// POST /api/receipts/holding-tax
  Future<dynamic> getReceiptData(int holdingTaxId) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.holdingTaxReceiptData,
      data: {'holding_tax_id': holdingTaxId},
    );
    return response.data;
  }
}
