import 'package:dio/dio.dart';
import '../../../core/network/endpoints/api_endpoints.dart';
import '../../../core/network/network_service.dart';

class NoticeAdminDataSource {
  /// GET /api/notices
  Future<dynamic> listNotices({
    String? status,
    String? type,
    String? priority,
    String? targetAudience,
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
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (targetAudience != null && targetAudience.isNotEmpty) {
      queryParams['target_audience'] = targetAudience;
    }
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await NetworkService.to.get(
      ApiEndpoints.adminNotices,
      queryParameters: queryParams,
    );
    return response.data;
  }

  /// GET /api/notices/{id}
  Future<dynamic> getNotice(int id) async {
    final response = await NetworkService.to.get(
      ApiEndpoints.adminNoticeDetail.replaceAll('{id}', id.toString()),
    );
    return response.data;
  }

  /// POST /api/notices (multipart if a PDF is attached, otherwise JSON)
  Future<dynamic> createNotice(
    Map<String, dynamic> data, {
    String? pdfFilePath,
    String? pdfFileName,
  }) async {
    if (pdfFilePath != null) {
      final formData = FormData.fromMap({
        ...data,
        'pdf_file': await MultipartFile.fromFile(pdfFilePath, filename: pdfFileName),
      });
      final response = await NetworkService.to.post(ApiEndpoints.adminNotices, data: formData);
      return response.data;
    }
    final response = await NetworkService.to.post(ApiEndpoints.adminNotices, data: data);
    return response.data;
  }

  /// PUT /api/notices/{id} (multipart if a new PDF is attached, otherwise JSON)
  Future<dynamic> updateNotice(
    int id,
    Map<String, dynamic> data, {
    String? pdfFilePath,
    String? pdfFileName,
  }) async {
    final url = ApiEndpoints.adminNoticeDetail.replaceAll('{id}', id.toString());
    if (pdfFilePath != null) {
      // Laravel needs a POST + _method override for multipart "PUT" requests.
      final formData = FormData.fromMap({
        ...data,
        '_method': 'PUT',
        'pdf_file': await MultipartFile.fromFile(pdfFilePath, filename: pdfFileName),
      });
      final response = await NetworkService.to.post(url, data: formData);
      return response.data;
    }
    final response = await NetworkService.to.put(url, data: data);
    return response.data;
  }

  /// DELETE /api/notices/{id}
  Future<dynamic> deleteNotice(int id) async {
    final response = await NetworkService.to.delete(
      ApiEndpoints.adminNoticeDetail.replaceAll('{id}', id.toString()),
    );
    return response.data;
  }

  /// POST /api/notices/{id}/publish
  Future<dynamic> publishNotice(int id, {String? adminRemarks}) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminNoticePublish.replaceAll('{id}', id.toString()),
      data: {if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks},
    );
    return response.data;
  }

  /// POST /api/notices/{id}/archive
  Future<dynamic> archiveNotice(int id, {String? adminRemarks}) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminNoticeArchive.replaceAll('{id}', id.toString()),
      data: {if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks},
    );
    return response.data;
  }

  /// POST /api/notices/{id}/toggle-pin
  Future<dynamic> togglePin(int id) async {
    final response = await NetworkService.to.post(
      ApiEndpoints.adminNoticeTogglePin.replaceAll('{id}', id.toString()),
    );
    return response.data;
  }

  /// GET /api/notices/stats/overview
  Future<dynamic> getStatistics() async {
    final response = await NetworkService.to.get(ApiEndpoints.adminNoticeStats);
    return response.data;
  }
}
