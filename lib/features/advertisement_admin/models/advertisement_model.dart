// Models for the Advertisement admin module.
//
// Mirrors `AdvertisementController` / `AdvertisementService` responses
// (table `advertisements`).

num _asNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  return 0;
}

class AdvertisementModel {
  final int id;
  final String? title;
  final String? description;
  final String advertiserName;
  final String advertiserType;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final String? websiteUrl;
  final String? imageUrl;
  final String? redirectUrl;
  final String position;
  final String status;
  final String? startDate;
  final String? endDate;
  final num amountPaid;
  final int impressions;
  final int clicks;
  final num ctr;
  final int priority;
  final String? adminRemarks;
  final String? createdByName;
  final String? updatedByName;
  final String? createdAt;
  final String? updatedAt;

  AdvertisementModel({
    required this.id,
    this.title,
    this.description,
    required this.advertiserName,
    required this.advertiserType,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.websiteUrl,
    this.imageUrl,
    this.redirectUrl,
    required this.position,
    required this.status,
    this.startDate,
    this.endDate,
    this.amountPaid = 0,
    this.impressions = 0,
    this.clicks = 0,
    this.ctr = 0,
    this.priority = 0,
    this.adminRemarks,
    this.createdByName,
    this.updatedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      advertiserName: json['advertiser_name']?.toString() ?? '',
      advertiserType: json['advertiser_type']?.toString() ?? 'other',
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      imageUrl: json['image_url']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      position: json['position']?.toString() ?? 'inline',
      status: json['status']?.toString() ?? 'draft',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      amountPaid: _asNum(json['amount_paid']),
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      ctr: _asNum(json['ctr']),
      priority: json['priority'] ?? 0,
      adminRemarks: json['admin_remarks']?.toString(),
      createdByName: json['created_by_name']?.toString(),
      updatedByName: json['updated_by_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get displayTitle => (title != null && title!.isNotEmpty) ? title! : advertiserName;
}

class AdListResult {
  final List<AdvertisementModel> ads;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  AdListResult({
    required this.ads,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory AdListResult.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return AdListResult(
      ads: (json['advertisements'] as List? ?? [])
          .map((e) => AdvertisementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
      total: pagination['total'] ?? 0,
      perPage: pagination['per_page'] ?? 15,
    );
  }
}

class AdStatsOverview {
  final int total;
  final int active;
  final int pending;
  final int paused;
  final int expired;
  final int rejected;

  AdStatsOverview({
    required this.total,
    required this.active,
    required this.pending,
    required this.paused,
    required this.expired,
    required this.rejected,
  });

  factory AdStatsOverview.fromJson(Map<String, dynamic> json) {
    return AdStatsOverview(
      total: json['total_advertisements'] ?? 0,
      active: json['active'] ?? 0,
      pending: json['pending'] ?? 0,
      paused: json['paused'] ?? 0,
      expired: json['expired'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

class AdPerformance {
  final int totalImpressions;
  final int totalClicks;
  final num clickThroughRate;
  final num totalRevenue;

  AdPerformance({
    required this.totalImpressions,
    required this.totalClicks,
    required this.clickThroughRate,
    required this.totalRevenue,
  });

  factory AdPerformance.fromJson(Map<String, dynamic> json) {
    return AdPerformance(
      totalImpressions: json['total_impressions'] ?? 0,
      totalClicks: json['total_clicks'] ?? 0,
      clickThroughRate: _asNum(json['click_through_rate']),
      totalRevenue: _asNum(json['total_revenue']),
    );
  }
}

class TopAd {
  final int id;
  final String? title;
  final String advertiserName;
  final int impressions;
  final int clicks;
  final num ctr;
  final num revenue;

  TopAd({
    required this.id,
    this.title,
    required this.advertiserName,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.revenue,
  });

  factory TopAd.fromJson(Map<String, dynamic> json) {
    return TopAd(
      id: json['id'] ?? 0,
      title: json['title']?.toString(),
      advertiserName: json['advertiser_name']?.toString() ?? '',
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      ctr: _asNum(json['ctr']),
      revenue: _asNum(json['revenue']),
    );
  }
}

class AdStatistics {
  final AdStatsOverview overview;
  final AdPerformance performance;
  final List<TopAd> topPerformingAds;

  AdStatistics({
    required this.overview,
    required this.performance,
    required this.topPerformingAds,
  });

  factory AdStatistics.fromJson(Map<String, dynamic> json) {
    return AdStatistics(
      overview: AdStatsOverview.fromJson(json['overview'] as Map<String, dynamic>? ?? {}),
      performance: AdPerformance.fromJson(json['performance'] as Map<String, dynamic>? ?? {}),
      topPerformingAds: (json['top_performing_ads'] as List? ?? [])
          .map((e) => TopAd.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
