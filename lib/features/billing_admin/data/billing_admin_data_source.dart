import 'package:dio/dio.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';
import '../models/billing_models.dart';

class BillingAdminDataSource {
  /// GET /api/billing/markets
  Future<dynamic> getMarkets() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminMarkets);
    return response.data;
  }

  /// GET /api/billing/shops/{marketId}/{shopNo}/bills
  Future<dynamic> getShopBills(String marketId, String shopNo) async {
    final response = await NetworkService.to.get(
      '/api/billing/shops/$marketId/$shopNo/bills',
    );
    return response.data;
  }

  /// GET /api/billing/shops/{marketId}/{shopNo}/outstanding
  Future<dynamic> getOutstanding(String marketId, String shopNo) async {
    final response = await NetworkService.to.get(
      '/api/billing/shops/$marketId/$shopNo/outstanding',
    );
    return response.data;
  }

  /// POST /api/billing/generate-monthly-bills
  Future<dynamic> generateMonthlyBills({
    required String billMonth,
    required List<BillRowInput> bills,
  }) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminGenerateBills,
      data: {
        'bill_month': billMonth,
        'bills': bills.map((b) => b.toJson()).toList(),
      },
    );
    return response.data;
  }

  /// POST /api/billing/upload-monthly-bills (multipart)
  Future<dynamic> uploadMonthlyBillingSheet({
    required String billMonth,
    required String filePath,
    required String fileName,
    String? sheetName,
  }) async {
    final formData = FormData.fromMap({
      'bill_month': billMonth,
      if (sheetName != null && sheetName.isNotEmpty) 'sheet_name': sheetName,
      'billing_file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await NetworkService.to.post(
      ApiEndpoints.adminUploadBillSheet,
      data: formData,
    );
    return response.data;
  }

  /// POST /api/billing/payments/update-status
  Future<dynamic> updatePaymentStatus({
    required int billId,
    int? paymentDetailId,
    String? orderId,
    String? paymentId,
    double? amount,
    required String status,
    String? paymentRemarks,
  }) async {
    final data = <String, dynamic>{
      'bill_id': billId,
      'status': status,
    };
    if (paymentDetailId != null) data['payment_detail_id'] = paymentDetailId;
    if (orderId != null && orderId.isNotEmpty) data['order_id'] = orderId;
    if (paymentId != null && paymentId.isNotEmpty) data['payment_id'] = paymentId;
    if (amount != null) data['amount'] = amount;
    if (paymentRemarks != null && paymentRemarks.isNotEmpty) {
      data['payment_remarks'] = paymentRemarks;
    }

    final response = await NetworkService.to.post(
      ApiEndpoints.adminUpdatePayment,
      data: data,
    );
    return response.data;
  }
}
