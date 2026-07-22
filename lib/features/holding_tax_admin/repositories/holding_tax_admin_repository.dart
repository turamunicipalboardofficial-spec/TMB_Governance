import '../../../core/error/error_handler.dart';
import '../data/holding_tax_admin_data_source.dart';
import '../models/holding_tax_model.dart';

class HoldingTaxAdminRepository {
  final HoldingTaxAdminDataSource _dataSource;

  HoldingTaxAdminRepository(this._dataSource);

  Future<List<HoldingTaxSearchItem>> search({String? query, String? type}) async {
    try {
      final response = await _dataSource.search(query: query, type: type);
      final data = response['data'] as List? ?? [];
      return data
          .map((e) => HoldingTaxSearchItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<HoldingTaxModel?> getDetails(String holdingNo) async {
    try {
      final response = await _dataSource.getDetails(holdingNo);
      if (response['data'] == null) return null;
      return HoldingTaxModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<HoldingTaxModel> pay({
    required String holdingNo,
    double? paidAmount,
    String? paymentRemarks,
  }) async {
    try {
      final response = await _dataSource.pay(
        holdingNo: holdingNo,
        paidAmount: paidAmount,
        paymentRemarks: paymentRemarks,
      );
      return HoldingTaxModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<HoldingTaxStats> getStats({String? type}) async {
    try {
      final response = await _dataSource.getStats(type: type);
      return HoldingTaxStats.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> getReceiptData(int holdingTaxId) async {
    try {
      final response = await _dataSource.getReceiptData(holdingTaxId);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
