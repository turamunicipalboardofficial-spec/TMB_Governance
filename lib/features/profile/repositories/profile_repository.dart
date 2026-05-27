import '../../../core/error/error_handler.dart';
import '../data/profile_data_source.dart';
import '../models/profile_update_request.dart';
import '../models/change_password_request.dart';

class ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepository(this._dataSource);

  Future<Map<String, dynamic>> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    try {
      return await _dataSource.updateProfile(request);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      return await _dataSource.changePassword(request);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (e) {
      // Ignore logout errors
    }
  }
}
