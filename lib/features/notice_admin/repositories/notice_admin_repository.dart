import '../../../core/error/error_handler.dart';
import '../data/notice_admin_data_source.dart';
import '../models/notice_model.dart';

class NoticeAdminRepository {
  final NoticeAdminDataSource _dataSource;

  NoticeAdminRepository(this._dataSource);

  Future<NoticeListResult> listNotices({
    String? status,
    String? type,
    String? priority,
    String? targetAudience,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
  }) async {
    try {
      final response = await _dataSource.listNotices(
        status: status,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        perPage: perPage,
      );
      return NoticeListResult.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> getNotice(int id) async {
    try {
      final response = await _dataSource.getNotice(id);
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> createNotice({
    required String title,
    required String content,
    String type = 'notice',
    String priority = 'medium',
    String status = 'draft',
    String? targetAudience,
    String? publishDate,
    String? expiryDate,
    bool isPinned = false,
    String? adminRemarks,
    String? pdfFilePath,
    String? pdfFileName,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'content': content,
        'type': type,
        'priority': priority,
        'status': status,
        'is_pinned': isPinned,
        if (targetAudience != null && targetAudience.isNotEmpty) 'target_audience': targetAudience,
        if (publishDate != null && publishDate.isNotEmpty) 'publish_date': publishDate,
        if (expiryDate != null && expiryDate.isNotEmpty) 'expiry_date': expiryDate,
        if (adminRemarks != null && adminRemarks.isNotEmpty) 'admin_remarks': adminRemarks,
      };
      final response = await _dataSource.createNotice(
        data,
        pdfFilePath: pdfFilePath,
        pdfFileName: pdfFileName,
      );
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> updateNotice({
    required int id,
    String? title,
    String? content,
    String? type,
    String? priority,
    String? status,
    String? targetAudience,
    String? publishDate,
    String? expiryDate,
    bool? isPinned,
    String? adminRemarks,
    String? pdfFilePath,
    String? pdfFileName,
    bool removePdf = false,
  }) async {
    try {
      final data = <String, dynamic>{
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (type != null) 'type': type,
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
        if (targetAudience != null) 'target_audience': targetAudience,
        if (publishDate != null) 'publish_date': publishDate,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (isPinned != null) 'is_pinned': isPinned,
        if (adminRemarks != null) 'admin_remarks': adminRemarks,
        if (removePdf) 'remove_pdf': true,
      };
      final response = await _dataSource.updateNotice(
        id,
        data,
        pdfFilePath: pdfFilePath,
        pdfFileName: pdfFileName,
      );
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> deleteNotice(int id) async {
    try {
      await _dataSource.deleteNotice(id);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> publishNotice(int id, {String? adminRemarks}) async {
    try {
      final response = await _dataSource.publishNotice(id, adminRemarks: adminRemarks);
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> archiveNotice(int id, {String? adminRemarks}) async {
    try {
      final response = await _dataSource.archiveNotice(id, adminRemarks: adminRemarks);
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeModel> togglePin(int id) async {
    try {
      final response = await _dataSource.togglePin(id);
      return NoticeModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  Future<NoticeStats> getStatistics() async {
    try {
      final response = await _dataSource.getStatistics();
      return NoticeStats.fromJson(response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
