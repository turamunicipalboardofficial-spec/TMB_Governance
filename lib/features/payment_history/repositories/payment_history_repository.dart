import '../../../core/error/error_handler.dart';
import '../data/payment_history_data_source.dart';
import '../models/payment_history_model.dart';

class PaymentHistoryRepository {
  final PaymentHistoryDataSource _dataSource;

  PaymentHistoryRepository(this._dataSource);

  Future<PaymentHistoryResult> getAdminPaymentHistory({
    String? status,
    String? formType,
    String? search,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final response = await _dataSource.getAdminPaymentHistory(
        status: status,
        formType: formType,
        search: search,
        perPage: perPage,
        page: page,
      );
      return PaymentHistoryResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
