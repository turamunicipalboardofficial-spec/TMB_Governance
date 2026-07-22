class GrievanceModel {
  final int id;
  final String grievanceId;
  final int? userId;
  final String name;
  final String? email;
  final String phone;
  final String? wardId;
  final String? locality;
  final String category;
  final String subject;
  final String description;
  final String? attachmentUrl;
  final String status;
  final String? adminRemarks;
  final String? resolvedBy;
  final String? resolvedAt;
  final String? createdAt;
  final String? updatedAt;

  GrievanceModel({
    required this.id,
    required this.grievanceId,
    this.userId,
    required this.name,
    this.email,
    required this.phone,
    this.wardId,
    this.locality,
    required this.category,
    required this.subject,
    required this.description,
    this.attachmentUrl,
    required this.status,
    this.adminRemarks,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory GrievanceModel.fromJson(Map<String, dynamic> json) {
    return GrievanceModel(
      id: json['id'] ?? 0,
      grievanceId: json['grievance_id'] ?? '',
      userId: json['user_id'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      wardId: json['ward_id']?.toString(),
      locality: json['locality'],
      category: json['category'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      attachmentUrl: json['attachment_url'],
      status: json['status'] ?? 'pending',
      adminRemarks: json['admin_remarks'],
      resolvedBy: json['resolved_by'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
}

/// Aggregate counts returned alongside the admin grievance list.
class GrievanceSummary {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final int rejected;

  GrievanceSummary({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.rejected,
  });

  factory GrievanceSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GrievanceSummary(total: 0, pending: 0, inProgress: 0, resolved: 0, rejected: 0);
    }
    return GrievanceSummary(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      resolved: json['resolved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}
