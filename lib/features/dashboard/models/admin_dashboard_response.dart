class AdminDashboardResponse {
  final SystemSummary systemSummary;
  final List<FormWiseAnalytic> formWiseAnalytics;
  final WorkflowAnalytics workflowAnalytics;
  final PendingActionsSection pendingActions;
  final PaymentRevenue paymentRevenue;

  AdminDashboardResponse({
    required this.systemSummary,
    required this.formWiseAnalytics,
    required this.workflowAnalytics,
    required this.pendingActions,
    required this.paymentRevenue,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    // form_wise_analytics can be either:
    //   { "form_wise_analytics": [...] }  ← nested object from API
    //   [...]                             ← direct list
    final fwaRaw = json['form_wise_analytics'];
    List<dynamic> fwaList = [];
    if (fwaRaw is List) {
      fwaList = fwaRaw;
    } else if (fwaRaw is Map) {
      final inner = fwaRaw['form_wise_analytics'];
      if (inner is List) fwaList = inner;
    }

    return AdminDashboardResponse(
      systemSummary: SystemSummary.fromJson(
        json['system_summary'] as Map<String, dynamic>? ?? {},
      ),
      formWiseAnalytics: fwaList
          .map((e) => FormWiseAnalytic.fromJson(e as Map<String, dynamic>))
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

class FormWiseAnalytic {
  final int? formTypeId;
  final String? formTypeName;
  final int? totalSubmitted;
  final int? totalApproved;
  final int? totalRejected;
  final int? totalPending;
  // Additional fields from API
  final int? todayApplications;
  final int? thisMonthApplications;
  final int? underReview;
  final int? paymentPending;
  final int? paymentCompleted;
  final int? paymentFailed;
  final num? revenueGenerated;
  final String? lastApplicationDate;
  final String? topStatus;

  FormWiseAnalytic({
    this.formTypeId,
    this.formTypeName,
    this.totalSubmitted,
    this.totalApproved,
    this.totalRejected,
    this.totalPending,
    this.todayApplications,
    this.thisMonthApplications,
    this.underReview,
    this.paymentPending,
    this.paymentCompleted,
    this.paymentFailed,
    this.revenueGenerated,
    this.lastApplicationDate,
    this.topStatus,
  });

  factory FormWiseAnalytic.fromJson(Map<String, dynamic> json) {
    return FormWiseAnalytic(
      // Support both old keys and new API keys
      formTypeId: json['form_type_id'],
      formTypeName: json['form_type_name'] ?? json['form_name'],
      totalSubmitted: json['total_submitted'] ?? json['total_applications'],
      totalApproved: json['total_approved'] ?? json['approved'],
      totalRejected: json['total_rejected'] ?? json['rejected'],
      totalPending: json['total_pending'] ?? json['pending'],
      todayApplications: json['today_applications'],
      thisMonthApplications: json['this_month_applications'],
      underReview: json['under_review'],
      paymentPending: json['payment_pending'],
      paymentCompleted: json['payment_completed'],
      paymentFailed: json['payment_failed'],
      revenueGenerated: json['revenue_generated'],
      lastApplicationDate: json['last_application_date'],
      topStatus: json['top_status'],
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
  final num totalRevenue;

  PaymentData({
    required this.totalTransactions,
    required this.successful,
    required this.failed,
    required this.pending,
    required this.refunded,
    required this.todayCollection,
    required this.weeklyCollection,
    required this.monthlyCollection,
    required this.totalRevenue,
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
      totalRevenue: json['total_revenue'] ?? 0,
    );
  }
}