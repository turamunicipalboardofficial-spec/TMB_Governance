import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class AdvertisementAdminDataSource {
  /// GET /api/advertisements
  Future<dynamic> listAds({
    String? status,
    String? advertiserType,
    String? position,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (advertiserType != null && advertiserType.isNotEmpty) queryParams['advertiser_type'] = advertiserType;
    if (position != null && position.isNotEmpty) queryParams['position'] = position;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminAds,
      queryParameters: queryParams,
    );
    return response.data;
  }

  /// GET /api/advertisements/{id}
  Future<dynamic> getAd(int id) async {
    final response = await NetworkService.to.get(
      ApiEndpoints.adminAdDetail.replaceAll('{id}', id.toString()),
    );
    return response.data;
  }

  /// POST /api/advertisements
  Future<dynamic> createAd(Map<String, dynamic> data) async {
    final response = await NetworkService.to.post(ApiEndpoints.adminAds, data: data);
    return response.data;
  }

  /// PUT /api/advertisements/{id}
  Future<dynamic> updateAd(int id, Map<String, dynamic> data) async {
    final response = await NetworkService.to.put(
      ApiEndpoints.adminAdDetail.replaceAll('{id}', id.toString()),
      data: data,
    );
    return response.data;
  }

  /// DELETE /api/advertisements/{id}
  Future<dynamic> deleteAd(int id) async {
    final response = await NetworkService.to.delete(
      ApiEndpoints.adminAdDetail.replaceAll('{id}', id.toString()),
    );
    return response.data;
  }

  /// POST /api/advertisements/{id}/publish
  Future<dynamic> publishAd(int id, {String? adminRemarks}) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminAdPublish.replaceAll('{id}', id.toString()),
      data: {if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks},
    );
    return response.data;
  }

  /// POST /api/advertisements/{id}/pause
  Future<dynamic> pauseAd(int id, {String? adminRemarks}) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminAdPause.replaceAll('{id}', id.toString()),
      data: {if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks},
    );
    return response.data;
  }

  /// POST /api/advertisements/{id}/reject
  Future<dynamic> rejectAd(int id, {String? adminRemarks}) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminAdReject.replaceAll('{id}', id.toString()),
      data: {if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks},
    );
    return response.data;
  }

  /// GET /api/advertisements/stats/overview
  Future<dynamic> getStatistics() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminAdStats);
    return response.data;
  }
}
