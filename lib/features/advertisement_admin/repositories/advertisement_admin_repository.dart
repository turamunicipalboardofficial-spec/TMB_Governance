import '../../../core/error/error_handler.dart';
import '../data/advertisement_admin_data_source.dart';
import '../models/advertisement_model.dart';

class AdvertisementAdminRepository {
  final AdvertisementAdminDataSource _dataSource;

  AdvertisementAdminRepository(this._dataSource);

  Future<AdListResult> listAds({
    String? status,
    String? advertiserType,
    String? position,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
  }) async {
    try {
      final response = await _dataSource.listAds(
        status: status,
        advertiserType: advertiserType,
        position: position,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        perPage: perPage,
      );
      return AdListResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> getAd(int id) async {
    try {
      final response = await _dataSource.getAd(id);
      final data = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(data['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> createAd({
    required String advertiserName,
    required String advertiserType,
    String? title,
    String? description,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    String? websiteUrl,
    String? imageUrl,
    String? redirectUrl,
    String position = 'inline',
    String status = 'draft',
    String? startDate,
    String? endDate,
    num amountPaid = 0,
    int priority = 0,
    String? adminRemarks,
  }) async {
    try {
      final data = <String, dynamic>{
        'advertiser_name': advertiserName,
        'advertiser_type': advertiserType,
        'position': position,
        'status': status,
        'amount_paid': amountPaid,
        'priority': priority,
        if (title != null && title.isNotEmpty) 'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (contactPerson != null && contactPerson.isNotEmpty) 'contact_person': contactPerson,
        if (contactPhone != null && contactPhone.isNotEmpty) 'contact_phone': contactPhone,
        if (contactEmail != null && contactEmail.isNotEmpty) 'contact_email': contactEmail,
        if (websiteUrl != null && websiteUrl.isNotEmpty) 'website_url': websiteUrl,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
        if (redirectUrl != null && redirectUrl.isNotEmpty) 'redirect_url': redirectUrl,
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks,
      };
      final response = await _dataSource.createAd(data);
      final resData = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(resData['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> updateAd({
    required int id,
    String? advertiserName,
    String? advertiserType,
    String? title,
    String? description,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    String? websiteUrl,
    String? imageUrl,
    String? redirectUrl,
    String? position,
    String? status,
    String? startDate,
    String? endDate,
    num? amountPaid,
    int? priority,
    String? adminRemarks,
  }) async {
    try {
      final data = <String, dynamic>{
        if (advertiserName != null) 'advertiser_name': advertiserName,
        if (advertiserType != null) 'advertiser_type': advertiserType,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (contactEmail != null) 'contact_email': contactEmail,
        if (websiteUrl != null) 'website_url': websiteUrl,
        if (imageUrl != null) 'image_url': imageUrl,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
        if (position != null) 'position': position,
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (amountPaid != null) 'amount_paid': amountPaid,
        if (priority != null) 'priority': priority,
        if (adminRemarks != null) 'admin_remarks': adminRemarks,
      };
      final response = await _dataSource.updateAd(id, data);
      final resData = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(resData['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> deleteAd(int id) async {
    try {
      await _dataSource.deleteAd(id);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> publishAd(int id, {String? adminRemarks}) async {
    try {
      final response = await _dataSource.publishAd(id, adminRemarks: adminRemarks);
      final data = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(data['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> pauseAd(int id, {String? adminRemarks}) async {
    try {
      final response = await _dataSource.pauseAd(id, adminRemarks: adminRemarks);
      final data = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(data['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdvertisementModel> rejectAd(int id, {String? adminRemarks}) async {
    try {
      final response = await _dataSource.rejectAd(id, adminRemarks: adminRemarks);
      final data = response['data'] as Map<String, dynamic>;
      return AdvertisementModel.fromJson(data['advertisement'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<AdStatistics> getStatistics() async {
    try {
      final response = await _dataSource.getStatistics();
      return AdStatistics.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
