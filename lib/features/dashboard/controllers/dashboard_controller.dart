import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/design_system/molecules/custom_snackbar.dart';
import '../models/admin_dashboard_response.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;

  DashboardController(this._repository);

  final dashboardData = Rxn<AdminDashboardResponse>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      dashboardData.value = await _repository.getDashboard();
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMsg = e.response?.data?['message'] ?? e.message;
      errorMessage.value = 'HTTP $statusCode: $serverMsg';
      if (kDebugMode) {
        print('Dashboard error: HTTP $statusCode - $serverMsg');
        print('URL: ${e.requestOptions.uri}');
        print('Response: ${e.response?.data}');
      }
      if (statusCode == 401) {
        CustomSnackbar.showError(
            'Session expired. Please log in again.');
      } else {
        CustomSnackbar.showError('Failed to load dashboard data ($statusCode)');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      if (kDebugMode) {
        print('Dashboard error: $e');
      }
      CustomSnackbar.showError('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }
}
