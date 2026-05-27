class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  // CEO / Admin
  static const adminMainShell = '/admin/main';
  static const adminDashboard = '/admin/dashboard';
  static const formApproval = '/admin/forms';
  static const formDetail = '/admin/forms/detail';
  static const jobList = '/admin/jobs';
  static const jobCreate = '/admin/jobs/create';
  static const jobEdit = '/admin/jobs/edit';
  static const renewalList = '/admin/trade-license/renewals';
  static const renewalDetail = '/admin/trade-license/renewals/detail';
  static const tradeLicenseStats = '/admin/trade-license/stats';
  static const holdingTaxStats = '/admin/holding-tax/stats';
  static const grievanceList = '/admin/grievances';
  static const grievanceDetail = '/admin/grievances/detail';
  static const billingDashboard = '/admin/billing';
  static const generateBills = '/admin/billing/generate';
  static const updatePayment = '/admin/billing/update-payment';
  static const garbageDashboard = '/admin/garbage';
  static const addTruck = '/admin/garbage/add-truck';
  static const assignDriver = '/admin/garbage/assign-driver';
  static const createSchedule = '/admin/garbage/create-schedule';
  static const adList = '/admin/advertisements';
  static const adCreate = '/admin/advertisements/create';
  static const adDetail = '/admin/advertisements/detail';
  static const adEdit = '/admin/advertisements/edit';
  static const noticeList = '/admin/notices';
  static const noticeCreate = '/admin/notices/create';
  static const noticeDetail = '/admin/notices/detail';
  static const noticeEdit = '/admin/notices/edit';
  static const notificationList = '/admin/notifications';
  static const broadcastNotification = '/admin/notifications/broadcast';
  static const sendToUser = '/admin/notifications/send-to-user';
  static const paymentHistory = '/admin/payment-history';
  static const petDogList = '/admin/pet-dog';
  static const petDogDetail = '/admin/pet-dog/detail';
  static const userRoleManagement = '/admin/users';
  static const createUser = '/admin/users/create';
  static const editUser = '/admin/users/edit';
  static const adminProfile = '/admin/profile';
  static const adminEditProfile = '/admin/profile/edit';
  static const adminChangePassword = '/admin/profile/change-password';

  // Driver
  static const driverHome = '/driver/home';
  static const driverDashboard = '/driver/dashboard';
  static const driverProfile = '/driver/profile';
}