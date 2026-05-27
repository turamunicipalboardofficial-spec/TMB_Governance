import '../../../core/error/error_handler.dart';
import '../data/dashboard_data_source.dart';
import '../models/admin_dashboard_response.dart';

class DashboardRepository {
  final DashboardDataSource _dataSource;

  DashboardRepository(this._dataSource);

  Future<AdminDashboardResponse> getDashboard() async {
    try {
      return await _dataSource.getDashboard();
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
