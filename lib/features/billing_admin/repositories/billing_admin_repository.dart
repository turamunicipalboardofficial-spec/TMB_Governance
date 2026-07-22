import '../../../core/error/error_handler.dart';
import '../data/billing_admin_data_source.dart';
import '../models/billing_models.dart';

class BillingAdminRepository {
  final BillingAdminDataSource _dataSource;

  BillingAdminRepository(this._dataSource);

  Future<List<MarketModel>> getMarkets() async {
    try {
      final response = await _dataSource.getMarkets();
      final data = response['data'] as List? ?? [];
      return data.map((e) => MarketModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<ShopBillsResult> getShopBills(String marketId, String shopNo) async {
    try {
      final response = await _dataSource.getShopBills(marketId, shopNo);
      return ShopBillsResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<OutstandingResult> getOutstanding(String marketId, String shopNo) async {
    try {
      final response = await _dataSource.getOutstanding(marketId, shopNo);
      return OutstandingResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<GenerateBillsResult> generateMonthlyBills({
    required String billMonth,
    required List<BillRowInput> bills,
  }) async {
    try {
      final response = await _dataSource.generateMonthlyBills(
        billMonth: billMonth,
        bills: bills,
      );
      return GenerateBillsResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<GenerateBillsResult> uploadMonthlyBillingSheet({
    required String billMonth,
    required String filePath,
    required String fileName,
    String? sheetName,
  }) async {
    try {
      final response = await _dataSource.uploadMonthlyBillingSheet(
        billMonth: billMonth,
        filePath: filePath,
        fileName: fileName,
        sheetName: sheetName,
      );
      return GenerateBillsResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<PaymentSyncResult> updatePaymentStatus({
    required int billId,
    int? paymentDetailId,
    String? orderId,
    String? paymentId,
    double? amount,
    required String status,
    String? paymentRemarks,
  }) async {
    try {
      final response = await _dataSource.updatePaymentStatus(
        billId: billId,
        paymentDetailId: paymentDetailId,
        orderId: orderId,
        paymentId: paymentId,
        amount: amount,
        status: status,
        paymentRemarks: paymentRemarks,
      );
      return PaymentSyncResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
