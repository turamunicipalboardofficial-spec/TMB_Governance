class AdminDashboardResponse {
  final SystemSummary systemSummary;
  final List<FormAnalytic> formWiseAnalytics;
  final WorkflowAnalytics workflowAnalytics;
  final PendingActionsSection pendingActions;
  final PaymentRevenue paymentRevenue;
  final BillingAnalytics billingAnalytics;
  final CitizenAnalytics citizenAnalytics;
  final AlertsSection alerts;
  final List<RecentActivity> recentActivities;
  final ChartsSection charts;

  AdminDashboardResponse({
    required this.systemSummary,
    required this.formWiseAnalytics,
    required this.workflowAnalytics,
    required this.pendingActions,
    required this.paymentRevenue,
    required this.billingAnalytics,
    required this.citizenAnalytics,
    required this.alerts,
    required this.recentActivities,
    required this.charts,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    // form_wise_analytics is wrapped: { "form_wise_analytics": [...] }
    final formWiseRaw = json['form_wise_analytics'];
    final List<dynamic> formList = formWiseRaw is Map
        ? (formWiseRaw['form_wise_analytics'] as List? ?? [])
        : (formWiseRaw as List? ?? []);

    // recent_activities is wrapped: { "recent_activities": [...] }
    final recentRaw = json['recent_activities'];
    final List<dynamic> recentList = recentRaw is Map
        ? (recentRaw['recent_activities'] as List? ?? [])
        : (recentRaw as List? ?? []);

    return AdminDashboardResponse(
      systemSummary: SystemSummary.fromJson(
        json['system_summary'] as Map<String, dynamic>? ?? {},
      ),
      formWiseAnalytics: formList
          .map((e) => FormAnalytic.fromJson(e as Map<String, dynamic>))
          .toList(),
      workflowAnalytics: WorkflowAnalytics.fromJson(
        json['workflow_analytics'] as Map<String, dynamic>? ?? {},
      ),
      pendingActions: PendingActionsSection.fromJson(
        json['pending_actions'] as Map<String, dynamic>? ?? {},
      ),
      paymentRevenue: PaymentRevenue.fromJson(
        json['payment_revenue'] as Map<String, dynamic>? ?? {},
      ),
      billingAnalytics: BillingAnalytics.fromJson(
        json['billing_analytics'] as Map<String, dynamic>? ?? {},
      ),
      citizenAnalytics: CitizenAnalytics.fromJson(
        json['citizen_analytics'] as Map<String, dynamic>? ?? {},
      ),
      alerts: AlertsSection.fromJson(
        json['alerts'] as Map<String, dynamic>? ?? {},
      ),
      recentActivities: recentList
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      charts: ChartsSection.fromJson(
        json['charts'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

// ─── System Summary ──────────────────────────────────────────────────────────

class SystemSummary {
  final int totalFormsSubmitted;
  final int totalPendingForms;
  final int totalApprovedForms;
  final int totalRejectedForms;
  final int totalUnderReviewForms;
  final int totalUsers;
  final int totalVerifiedUsers;
  final int totalUnverifiedUsers;
  final int totalPayments;
  final int successfulPayments;
  final int failedPayments;
  final int pendingPayments;
  final int refundedPayments;
  final num totalRevenue;
  final num todayRevenue;
  final num thisMonthRevenue;
  final num lastMonthRevenue;
  final num revenueGrowthPercentage;

  SystemSummary({
    required this.totalFormsSubmitted,
    required this.totalPendingForms,
    required this.totalApprovedForms,
    required this.totalRejectedForms,
    required this.totalUnderReviewForms,
    required this.totalUsers,
    required this.totalVerifiedUsers,
    required this.totalUnverifiedUsers,
    required this.totalPayments,
    required this.successfulPayments,
    required this.failedPayments,
    required this.pendingPayments,
    required this.refundedPayments,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.thisMonthRevenue,
    required this.lastMonthRevenue,
    required this.revenueGrowthPercentage,
  });

  factory SystemSummary.fromJson(Map<String, dynamic> json) {
    return SystemSummary(
      totalFormsSubmitted: json['total_forms_submitted'] ?? 0,
      totalPendingForms: json['total_pending_forms'] ?? 0,
      totalApprovedForms: json['total_approved_forms'] ?? 0,
      totalRejectedForms: json['total_rejected_forms'] ?? 0,
      totalUnderReviewForms: json['total_under_review_forms'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalVerifiedUsers: json['total_verified_users'] ?? 0,
      totalUnverifiedUsers: json['total_unverified_users'] ?? 0,
      totalPayments: json['total_payments'] ?? 0,
      successfulPayments: json['successful_payments'] ?? 0,
      failedPayments: json['failed_payments'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      refundedPayments: json['refunded_payments'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      todayRevenue: json['today_revenue'] ?? 0,
      thisMonthRevenue: json['this_month_revenue'] ?? 0,
      lastMonthRevenue: json['last_month_revenue'] ?? 0,
      revenueGrowthPercentage: json['revenue_growth_percentage'] ?? 0,
    );
  }
}

// ─── Form-wise Analytics ─────────────────────────────────────────────────────

class FormAnalytic {
  final String formName;
  final int totalApplications;
  final int todayApplications;
  final int thisMonthApplications;
  final int pending;
  final int approved;
  final int rejected;
  final int underReview;
  final int paymentPending;
  final int paymentCompleted;
  final int paymentFailed;
  final num revenueGenerated;
  final int renewals;
  final int newApplicationsCount;
  final num averageProcessingDays;
  final String? lastApplicationDate;
  final String topStatus;

  FormAnalytic({
    required this.formName,
    required this.totalApplications,
    required this.todayApplications,
    required this.thisMonthApplications,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.underReview,
    required this.paymentPending,
    required this.paymentCompleted,
    required this.paymentFailed,
    required this.revenueGenerated,
    required this.renewals,
    required this.newApplicationsCount,
    required this.averageProcessingDays,
    this.lastApplicationDate,
    required this.topStatus,
  });

  factory FormAnalytic.fromJson(Map<String, dynamic> json) {
    return FormAnalytic(
      formName: json['form_name'] ?? 'Unknown',
      totalApplications: json['total_applications'] ?? 0,
      todayApplications: json['today_applications'] ?? 0,
      thisMonthApplications: json['this_month_applications'] ?? 0,
      pending: json['pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
      underReview: json['under_review'] ?? 0,
      paymentPending: json['payment_pending'] ?? 0,
      paymentCompleted: json['payment_completed'] ?? 0,
      paymentFailed: json['payment_failed'] ?? 0,
      revenueGenerated: json['revenue_generated'] ?? 0,
      renewals: json['renewals'] ?? 0,
      newApplicationsCount: json['new_applications_count'] ?? 0,
      averageProcessingDays: json['average_processing_days'] ?? 0,
      lastApplicationDate: json['last_application_date'],
      topStatus: json['top_status'] ?? '',
    );
  }
}

// ─── Workflow Analytics ──────────────────────────────────────────────────────

class WorkflowAnalytics {
  final WorkflowData workflow;

  WorkflowAnalytics({required this.workflow});

  factory WorkflowAnalytics.fromJson(Map<String, dynamic> json) {
    return WorkflowAnalytics(
      workflow: WorkflowData.fromJson(
        json['workflow'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class WorkflowData {
  final int submitted;
  final int documentVerification;
  final int fieldInspection;
  final int paymentPending;
  final int paymentCompleted;
  final int approvalPending;
  final int approved;
  final int rejected;

  WorkflowData({
    required this.submitted,
    required this.documentVerification,
    required this.fieldInspection,
    required this.paymentPending,
    required this.paymentCompleted,
    required this.approvalPending,
    required this.approved,
    required this.rejected,
  });

  factory WorkflowData.fromJson(Map<String, dynamic> json) {
    return WorkflowData(
      submitted: json['submitted'] ?? 0,
      documentVerification: json['document_verification'] ?? 0,
      fieldInspection: json['field_inspection'] ?? 0,
      paymentPending: json['payment_pending'] ?? 0,
      paymentCompleted: json['payment_completed'] ?? 0,
      approvalPending: json['approval_pending'] ?? 0,
      approved: json['approved'] ?? 0,
      rejected: json['rejected'] ?? 0,
    );
  }
}

// ─── Pending Actions ─────────────────────────────────────────────────────────

class PendingActionsSection {
  final PendingActionsData pendingActions;

  PendingActionsSection({required this.pendingActions});

  factory PendingActionsSection.fromJson(Map<String, dynamic> json) {
    return PendingActionsSection(
      pendingActions: PendingActionsData.fromJson(
        json['pending_actions'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PendingActionsData {
  final int totalPending;
  final int paymentPending;
  final int verificationPending;
  final int inspectionPending;
  final int highPriorityPending;
  final int oldestPendingDays;
  final List<dynamic> urgentCases;

  PendingActionsData({
    required this.totalPending,
    required this.paymentPending,
    required this.verificationPending,
    required this.inspectionPending,
    required this.highPriorityPending,
    required this.oldestPendingDays,
    required this.urgentCases,
  });

  factory PendingActionsData.fromJson(Map<String, dynamic> json) {
    return PendingActionsData(
      totalPending: json['total_pending'] ?? 0,
      paymentPending: json['payment_pending'] ?? 0,
      verificationPending: json['verification_pending'] ?? 0,
      inspectionPending: json['inspection_pending'] ?? 0,
      highPriorityPending: json['high_priority_pending'] ?? 0,
      oldestPendingDays: json['oldest_pending_days'] ?? 0,
      urgentCases: json['urgent_cases'] as List? ?? [],
    );
  }
}

// ─── Payment Revenue ─────────────────────────────────────────────────────────

class PaymentRevenue {
  final PaymentData payments;

  PaymentRevenue({required this.payments});

  factory PaymentRevenue.fromJson(Map<String, dynamic> json) {
    return PaymentRevenue(
      payments: PaymentData.fromJson(
        json['payments'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class PaymentData {
  final int totalTransactions;
  final int successful;
  final int failed;
  final int pending;
  final int refunded;
  final num todayCollection;
  final num weeklyCollection;
  final num monthlyCollection;
  final num yearlyCollection;
  final int onlinePayments;
  final int offlinePayments;
  final int upiPayments;
  final int cardPayments;
  final int netbankingPayments;
  final num averageTransactionValue;

  PaymentData({
    required this.totalTransactions,
    required this.successful,
    required this.failed,
    required this.pending,
    required this.refunded,
    required this.todayCollection,
    required this.weeklyCollection,
    required this.monthlyCollection,
    required this.yearlyCollection,
    required this.onlinePayments,
    required this.offlinePayments,
    required this.upiPayments,
    required this.cardPayments,
    required this.netbankingPayments,
    required this.averageTransactionValue,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      totalTransactions: json['total_transactions'] ?? 0,
      successful: json['successful'] ?? 0,
      failed: json['failed'] ?? 0,
      pending: json['pending'] ?? 0,
      refunded: json['refunded'] ?? 0,
      todayCollection: json['today_collection'] ?? 0,
      weeklyCollection: json['weekly_collection'] ?? 0,
      monthlyCollection: json['monthly_collection'] ?? 0,
      yearlyCollection: json['yearly_collection'] ?? 0,
      onlinePayments: json['online_payments'] ?? 0,
      offlinePayments: json['offline_payments'] ?? 0,
      upiPayments: json['upi_payments'] ?? 0,
      cardPayments: json['card_payments'] ?? 0,
      netbankingPayments: json['netbanking_payments'] ?? 0,
      averageTransactionValue: json['average_transaction_value'] ?? 0,
    );
  }
}

// ─── Billing Analytics ───────────────────────────────────────────────────────

class BillingAnalytics {
  final BillingData billing;

  BillingAnalytics({required this.billing});

  factory BillingAnalytics.fromJson(Map<String, dynamic> json) {
    return BillingAnalytics(
      billing: BillingData.fromJson(
        json['billing'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class BillingData {
  final int totalMarkets;
  final int totalShops;
  final int occupiedShops;
  final int vacantShops;
  final int billsGeneratedThisMonth;
  final num collectedAmount;
  final num outstandingAmount;
  final num overdueAmount;
  final num collectionRate;
  final int paidShops;
  final int unpaidShops;

  BillingData({
    required this.totalMarkets,
    required this.totalShops,
    required this.occupiedShops,
    required this.vacantShops,
    required this.billsGeneratedThisMonth,
    required this.collectedAmount,
    required this.outstandingAmount,
    required this.overdueAmount,
    required this.collectionRate,
    required this.paidShops,
    required this.unpaidShops,
  });

  factory BillingData.fromJson(Map<String, dynamic> json) {
    return BillingData(
      totalMarkets: json['total_markets'] ?? 0,
      totalShops: json['total_shops'] ?? 0,
      occupiedShops: json['occupied_shops'] ?? 0,
      vacantShops: json['vacant_shops'] ?? 0,
      billsGeneratedThisMonth: json['bills_generated_this_month'] ?? 0,
      collectedAmount: json['collected_amount'] ?? 0,
      outstandingAmount: json['outstanding_amount'] ?? 0,
      overdueAmount: json['overdue_amount'] ?? 0,
      collectionRate: json['collection_rate'] ?? 0,
      paidShops: json['paid_shops'] ?? 0,
      unpaidShops: json['unpaid_shops'] ?? 0,
    );
  }
}

// ─── Citizen Analytics ───────────────────────────────────────────────────────

class CitizenAnalytics {
  final CitizenData citizens;

  CitizenAnalytics({required this.citizens});

  factory CitizenAnalytics.fromJson(Map<String, dynamic> json) {
    return CitizenAnalytics(
      citizens: CitizenData.fromJson(
        json['citizens'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CitizenData {
  final int totalRegistered;
  final int verifiedUsers;
  final int unverifiedUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int newUsersToday;
  final int newUsersThisMonth;
  final int maleUsers;
  final int femaleUsers;
  final int otherUsers;

  CitizenData({
    required this.totalRegistered,
    required this.verifiedUsers,
    required this.unverifiedUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.newUsersToday,
    required this.newUsersThisMonth,
    required this.maleUsers,
    required this.femaleUsers,
    required this.otherUsers,
  });

  factory CitizenData.fromJson(Map<String, dynamic> json) {
    return CitizenData(
      totalRegistered: json['total_registered'] ?? 0,
      verifiedUsers: json['verified_users'] ?? 0,
      unverifiedUsers: json['unverified_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      inactiveUsers: json['inactive_users'] ?? 0,
      newUsersToday: json['new_users_today'] ?? 0,
      newUsersThisMonth: json['new_users_this_month'] ?? 0,
      maleUsers: json['male_users'] ?? 0,
      femaleUsers: json['female_users'] ?? 0,
      otherUsers: json['other_users'] ?? 0,
    );
  }
}

// ─── Alerts ───────────────────────────────────────────────────────────────────

class AlertsSection {
  final AlertsData alerts;

  AlertsSection({required this.alerts});

  factory AlertsSection.fromJson(Map<String, dynamic> json) {
    return AlertsSection(
      alerts: AlertsData.fromJson(
        json['alerts'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class AlertsData {
  final int pendingApprovals;
  final int failedPayments;
  final int expiringTradeLicenses;
  final int highDueAccounts;
  final int systemErrors;

  AlertsData({
    required this.pendingApprovals,
    required this.failedPayments,
    required this.expiringTradeLicenses,
    required this.highDueAccounts,
    required this.systemErrors,
  });

  factory AlertsData.fromJson(Map<String, dynamic> json) {
    return AlertsData(
      pendingApprovals: json['pending_approvals'] ?? 0,
      failedPayments: json['failed_payments'] ?? 0,
      expiringTradeLicenses: json['expiring_trade_licenses'] ?? 0,
      highDueAccounts: json['high_due_accounts'] ?? 0,
      systemErrors: json['system_errors'] ?? 0,
    );
  }

  /// True if there's anything worth surfacing to the admin.
  bool get hasAlerts =>
      pendingApprovals > 0 ||
      failedPayments > 0 ||
      expiringTradeLicenses > 0 ||
      highDueAccounts > 0 ||
      systemErrors > 0;
}

// ─── Recent Activities ───────────────────────────────────────────────────────

class RecentActivity {
  final String type;
  final String message;
  final String? dateTime;

  RecentActivity({
    required this.type,
    required this.message,
    this.dateTime,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? 'default',
      message: json['message'] ?? '',
      dateTime: json['date_time'],
    );
  }
}

// ─── Charts ───────────────────────────────────────────────────────────────────

class ChartsSection {
  final ChartsData charts;

  ChartsSection({required this.charts});

  factory ChartsSection.fromJson(Map<String, dynamic> json) {
    return ChartsSection(
      charts: ChartsData.fromJson(
        json['charts'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ChartsData {
  final List<DailyApplicationPoint> dailyApplications;
  final List<DailyRevenuePoint> dailyRevenue;
  final List<MonthlyApplicationPoint> monthlyApplications;
  final List<MonthlyRevenuePoint> monthlyRevenue;
  final List<ServiceRevenuePoint> serviceWiseRevenue;
  final List<PaymentTrendPoint> paymentTrends;

  ChartsData({
    required this.dailyApplications,
    required this.dailyRevenue,
    required this.monthlyApplications,
    required this.monthlyRevenue,
    required this.serviceWiseRevenue,
    required this.paymentTrends,
  });

  factory ChartsData.fromJson(Map<String, dynamic> json) {
    return ChartsData(
      dailyApplications: (json['daily_applications'] as List? ?? [])
          .map((e) => DailyApplicationPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyRevenue: (json['daily_revenue'] as List? ?? [])
          .map((e) => DailyRevenuePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyApplications: (json['monthly_applications'] as List? ?? [])
          .map((e) => MonthlyApplicationPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyRevenue: (json['monthly_revenue'] as List? ?? [])
          .map((e) => MonthlyRevenuePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      serviceWiseRevenue: (json['service_wise_revenue'] as List? ?? [])
          .map((e) => ServiceRevenuePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentTrends: (json['payment_trends'] as List? ?? [])
          .map((e) => PaymentTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyApplicationPoint {
  final String date;
  final int count;

  DailyApplicationPoint({required this.date, required this.count});

  factory DailyApplicationPoint.fromJson(Map<String, dynamic> json) {
    return DailyApplicationPoint(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DailyRevenuePoint {
  final String date;
  final num amount;

  DailyRevenuePoint({required this.date, required this.amount});

  factory DailyRevenuePoint.fromJson(Map<String, dynamic> json) {
    return DailyRevenuePoint(
      date: json['date'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }
}

class MonthlyApplicationPoint {
  final String month;
  final int count;

  MonthlyApplicationPoint({required this.month, required this.count});

  factory MonthlyApplicationPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyApplicationPoint(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class MonthlyRevenuePoint {
  final String month;
  final num amount;

  MonthlyRevenuePoint({required this.month, required this.amount});

  factory MonthlyRevenuePoint.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenuePoint(
      month: json['month'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }
}

class ServiceRevenuePoint {
  final String service;
  final num revenue;

  ServiceRevenuePoint({required this.service, required this.revenue});

  factory ServiceRevenuePoint.fromJson(Map<String, dynamic> json) {
    return ServiceRevenuePoint(
      service: json['service'] ?? '',
      revenue: json['revenue'] ?? 0,
    );
  }
}

class PaymentTrendPoint {
  final String date;
  final int count;
  final num amount;

  PaymentTrendPoint({
    required this.date,
    required this.count,
    required this.amount,
  });

  factory PaymentTrendPoint.fromJson(Map<String, dynamic> json) {
    return PaymentTrendPoint(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      amount: json['amount'] ?? 0,
    );
  }
}
