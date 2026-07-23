// Models for the Notices & Announcements admin module.
//
// Mirrors `NoticeAnnouncementController` / `NoticeAnnouncementService`
// responses (table `notices_announcements`).

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

class NoticeUserRef {
  final int id;
  final String name;

  NoticeUserRef({required this.id, required this.name});

  factory NoticeUserRef.fromJson(Map<String, dynamic> json) {
    final first = json['firstname']?.toString() ?? '';
    final last = json['lastname']?.toString() ?? '';
    return NoticeUserRef(
      id: json['id'] ?? 0,
      name: '$first $last'.trim(),
    );
  }
}

class NoticeModel {
  final int id;
  final String title;
  final String content;
  final String type; // notice | announcement
  final String priority; // low | medium | high | urgent
  final String status; // draft | published | archived
  final String? targetAudience;
  final String? attachmentUrl;
  final String? publishDate;
  final String? expiryDate;
  final bool isPinned;
  final String? adminRemarks;
  final NoticeUserRef? creator;
  final NoticeUserRef? updater;
  final String? createdAt;
  final String? updatedAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.status,
    this.targetAudience,
    this.attachmentUrl,
    this.publishDate,
    this.expiryDate,
    this.isPinned = false,
    this.adminRemarks,
    this.creator,
    this.updater,
    this.createdAt,
    this.updatedAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'notice',
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'draft',
      targetAudience: json['target_audience']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      publishDate: json['publish_date']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      isPinned: _asBool(json['is_pinned']),
      adminRemarks: json['admin_remarks']?.toString(),
      creator: json['creator'] != null
          ? NoticeUserRef.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      updater: json['updater'] != null
          ? NoticeUserRef.fromJson(json['updater'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get isAnnouncement => type == 'announcement';
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
}

class NoticeListResult {
  final List<NoticeModel> items;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  NoticeListResult({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory NoticeListResult.fromJson(Map<String, dynamic> json) {
    return NoticeListResult(
      items: (json['items'] as List? ?? [])
          .map((e) => NoticeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
    );
  }
}

class NoticeStats {
  final int total;
  final int published;
  final int draft;
  final int archived;
  final int notices;
  final int announcements;
  final int pinned;

  NoticeStats({
    required this.total,
    required this.published,
    required this.draft,
    required this.archived,
    required this.notices,
    required this.announcements,
    required this.pinned,
  });

  factory NoticeStats.fromJson(Map<String, dynamic> json) {
    final byStatus = json['by_status'] as Map<String, dynamic>? ?? {};
    final byType = json['by_type'] as Map<String, dynamic>? ?? {};
    return NoticeStats(
      total: json['total'] ?? 0,
      published: byStatus['published'] ?? 0,
      draft: byStatus['draft'] ?? 0,
      archived: byStatus['archived'] ?? 0,
      notices: byType['notices'] ?? 0,
      announcements: byType['announcements'] ?? 0,
      pinned: json['pinned'] ?? 0,
    );
  }
}
