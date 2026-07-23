class ApiEndpoints {
  // ── Auth ──────────────────────────────────────
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password';
  static const String profileUpdate = '/api/profileUpdate';
  static const String changePassword = '/api/changePassword';
  static const String wardList = '/api/getWardList';
  static const String localityList = '/api/getLocalityList';

  // ── Admin — Dashboard ─────────────────────────
  static const String adminDashboard = '/api/dashboard/admin';
  static const String adminPaymentHistory = '/api/dashboard/admin/payment-history';

  // ── Admin — Forms ─────────────────────────────
  static const String adminGetAllForms = '/api/getAllForms';
  static const String adminFormStats =
      '/api/admin/getFormsPercentageBasedOnDate';
  static const String adminApproveRejectForm =
      '/api/submitForm';
  static const String adminTradeLicenseFee = '/api/admin/tradeLicenseFee';
  static const String adminGeneratePetDogCert =
      '/api/admin/generatePetDogCertificate';

  // ── Admin — Jobs ──────────────────────────────
  static const String adminCreateJob = '/api/admin/createJobPosting';
  static const String adminGetAllJobs = '/api/admin/getAllJobPostings';
  static const String adminGetJobById = '/api/admin/getJobPostingById';
  static const String adminUpdateJob = '/api/admin/updateJobPosting';
  static const String adminDeleteJob = '/api/admin/deleteJobPosting';

  // ── Admin — Trade License ─────────────────────
  static const String adminRenewals = '/api/admin/trade-license/renewals';
  static const String adminApproveRenewal =
      '/api/admin/trade-license/approve-renewal';
  static const String adminRejectRenewal =
      '/api/admin/trade-license/reject-renewal';
  static const String adminCompleteRenewal =
      '/api/admin/trade-license/complete-renewal';
  static const String adminTradeLicenseStats = '/api/admin/trade-license/stats';
  static const String adminTradeLicenseBroadcast =
      '/api/admin/trade-license/broadcast-notification';

  // ── Admin — Holding Tax ───────────────────────
  static const String holdingTaxSearch = '/api/holding-taxes/search';
  static const String holdingTaxDetails = '/api/holding-taxes/details';
  static const String holdingTaxPay = '/api/holding-taxes/pay';
  static const String adminHoldingTaxStats = '/api/holding-taxes/stats';
  static const String holdingTaxReceiptData = '/api/receipts/holding-tax';
  static const String holdingTaxReceiptDownload = '/api/receipts/holding-tax/download';
  static const String holdingTaxReceiptHtml = '/api/receipts/holding-tax/html';

  // ── Admin — Grievances ────────────────────────
  static const String adminGrievancesAll = '/api/grievances/admin/all';
  static const String adminUpdateGrievance =
      '/api/grievances/admin/update-status';
  static const String grievanceCategories = '/api/grievances/categories';

  // ── Admin — Billing ───────────────────────────
  static const String adminGenerateBills = '/api/billing/generate-monthly-bills';
  static const String adminUploadBillSheet = '/api/billing/upload-monthly-bills';
  static const String adminUpdatePayment = '/api/billing/payments/update-status';
  static const String adminMarkets = '/api/billing/markets';

  // ── Admin — Garbage Trucks ────────────────────
  static const String trucksByWard = '/api/trucks/ward/{wardId}';
  static const String adminTrucks = '/api/admin/trucks';
  static const String adminUpdateTruck = '/api/admin/trucks/{id}';
  static const String adminListDrivers = '/api/admin/trucks/drivers';
  static const String adminAssignDriver = '/api/admin/trucks/assign-driver';
  static const String adminCreateSchedule = '/api/admin/trucks/schedule';
  static const String adminGarbageDashboard = '/api/admin/trucks/dashboard';

  // ── Admin — Advertisements ────────────────────
  static const String adminAds = '/api/admin/advertisements';
  static const String adminAdPublish = '/api/admin/advertisements/{id}/publish';
  static const String adminAdPause = '/api/admin/advertisements/{id}/pause';
  static const String adminAdReject = '/api/admin/advertisements/{id}/reject';
  static const String adminAdStats = '/api/admin/advertisements/statistics';

  // ── Admin — Notices / Announcements ───────────
  static const String adminNotices = '/api/notices';
  static const String adminNoticeDetail = '/api/notices/{id}';
  static const String adminNoticePublish = '/api/notices/{id}/publish';
  static const String adminNoticeArchive = '/api/notices/{id}/archive';
  static const String adminNoticeTogglePin = '/api/notices/{id}/toggle-pin';
  static const String adminNoticeStats = '/api/notices/stats/overview';
  static const String noticeDownloadPdf = '/api/feed/notices/{id}/download-pdf';

  // ── Admin — Notifications ─────────────────────
  static const String adminNotifications = '/api/admin/notifications';
  static const String adminBroadcast = '/api/admin/notifications/broadcast';
  static const String adminSendToUser = '/api/admin/notifications/send-to-user';
  static const String adminNotificationStats =
      '/api/admin/notifications/statistics';

  // ── Admin — Pet Dog ───────────────────────────
  static const String adminPetDogApps = '/api/admin/pet-dog/applications';
  static const String adminPetDogDetail = '/api/admin/pet-dog/application';
  static const String adminPetDogUpdatePayment =
      '/api/admin/pet-dog/update-payment';

  // ── Admin — User Management ───────────────────
  static const String adminCreateDriver = '/api/admin/users/driver';
  static const String adminCreateEmployee = '/api/admin/users/employee';
  static const String adminCreateConsumer = '/api/admin/users/consumer';
  static const String adminListUsers = '/api/admin/users';
  static const String adminUpdateUser = '/api/admin/users/{id}';
  static const String adminUpdateDriver = '/api/admin/users/driver/{id}';
  static const String adminToggleUserActive = '/api/admin/users/{id}/toggle-active';

  // ── Driver ────────────────────────────────────
  static const String driverLogin = '/api/driver/login';
  static const String driverStartShift = '/api/driver/shift/start';
  static const String driverEndShift = '/api/driver/shift/end';
  static const String driverUpdateLocation = '/api/driver/location/update';
  static const String driverAssignedRoute = '/api/driver/route';

  // ── Trade License (FCM Token) ─────────────────
  static const String saveFcmToken = '/api/trade-license/save-fcm-token';
  static const String removeFcmToken = '/api/trade-license/remove-fcm-token';
}
