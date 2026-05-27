import 'package:get/get.dart';
import '../features/splash/splash_binding.dart';
import '../features/splash/views/splash_screen.dart';
import '../features/auth/auth_binding.dart';
import '../features/auth/views/login_screen.dart';
import '../features/main_shell/main_shell_binding.dart';
import '../features/main_shell/views/main_shell_screen.dart';
import '../features/dashboard/dashboard_binding.dart';
import '../features/dashboard/views/dashboard_screen.dart';
import '../features/form_approval/form_approval_binding.dart';
import '../features/form_approval/views/form_list_screen.dart';
import '../features/form_approval/views/form_detail_screen.dart';
import '../features/job_posting/job_posting_binding.dart';
import '../features/job_posting/views/job_list_screen.dart';
import '../features/job_posting/views/job_create_screen.dart';
import '../features/trade_license_admin/trade_license_admin_binding.dart';
import '../features/trade_license_admin/views/renewal_list_screen.dart';
import '../features/trade_license_admin/views/renewal_detail_screen.dart';
import '../features/trade_license_admin/views/trade_license_stats_screen.dart';
import '../features/grievance_admin/grievance_admin_binding.dart';
import '../features/grievance_admin/views/grievance_list_screen.dart';
import '../features/grievance_admin/views/grievance_detail_screen.dart';
import '../features/holding_tax_admin/holding_tax_admin_binding.dart';
import '../features/holding_tax_admin/views/holding_tax_stats_screen.dart';
import '../features/billing_admin/billing_admin_binding.dart';
import '../features/billing_admin/views/billing_dashboard_screen.dart';
import '../features/billing_admin/views/generate_bills_screen.dart';
import '../features/billing_admin/views/update_payment_screen.dart';
import '../features/garbage_admin/garbage_admin_binding.dart';
import '../features/garbage_admin/views/garbage_dashboard_screen.dart';
import '../features/garbage_admin/views/add_truck_screen.dart';
import '../features/garbage_admin/views/assign_driver_screen.dart';
import '../features/garbage_admin/views/create_schedule_screen.dart';
import '../features/garbage_driver/garbage_driver_binding.dart';
import '../features/garbage_driver/views/driver_home_screen.dart';
import '../features/garbage_truck_tracking/driver_dashboard_binding.dart';
import '../features/garbage_truck_tracking/views/widgets/driver/driver_view.dart';
import '../features/advertisement_admin/advertisement_admin_binding.dart';
import '../features/advertisement_admin/views/ad_list_screen.dart';
import '../features/advertisement_admin/views/ad_create_screen.dart';
import '../features/advertisement_admin/views/ad_detail_screen.dart';
import '../features/notice_admin/notice_admin_binding.dart';
import '../features/notice_admin/views/notice_list_screen.dart';
import '../features/notice_admin/views/notice_create_screen.dart';
import '../features/notice_admin/views/notice_detail_screen.dart';
import '../features/notification_admin/notification_admin_binding.dart';
import '../features/notification_admin/views/notification_list_screen.dart';
import '../features/notification_admin/views/broadcast_screen.dart';
import '../features/notification_admin/views/send_to_user_screen.dart';
import '../features/payment_history/payment_history_binding.dart';
import '../features/payment_history/views/payment_history_screen.dart';
import '../features/pet_dog_admin/pet_dog_admin_binding.dart';
import '../features/pet_dog_admin/views/pet_dog_list_screen.dart';
import '../features/pet_dog_admin/views/pet_dog_detail_screen.dart';
import '../features/user_management/user_management_binding.dart';
import '../features/user_management/views/user_list_screen.dart';
import '../features/user_management/views/create_user_screen.dart';
import '../features/user_management/views/edit_user_screen.dart';
import '../features/profile/profile_binding.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/profile/views/change_password_screen.dart';
import '../core/network/interceptors/auth_interceptor.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),

    // Admin Main Shell (CEO + Admin + Employee)
    GetPage(
      name: AppRoutes.adminMainShell,
      page: () => const MainShellScreen(),
      binding: MainShellBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin', 'employee']),
      ],
    ),

    // Dashboard (CEO only)
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),

    // Forms (CEO + Admin + Editor/Employee)
    GetPage(
      name: AppRoutes.formApproval,
      page: () => const FormListScreen(),
      binding: FormApprovalBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin', 'editor']),
      ],
    ),
    GetPage(
      name: AppRoutes.formDetail,
      page: () => const FormDetailScreen(),
      binding: FormApprovalBinding(),
    ),

    // Jobs (CEO only)
    GetPage(
      name: AppRoutes.jobList,
      page: () => const JobListScreen(),
      binding: JobPostingBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.jobCreate,
      page: () => const JobCreateScreen(),
      binding: JobPostingBinding(),
    ),

    // Trade License Renewals (CEO only)
    GetPage(
      name: AppRoutes.renewalList,
      page: () => const RenewalListScreen(),
      binding: TradeLicenseAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.renewalDetail,
      page: () => const RenewalDetailScreen(),
      binding: TradeLicenseAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.tradeLicenseStats,
      page: () => const TradeLicenseStatsScreen(),
      binding: TradeLicenseAdminBinding(),
    ),

    // Holding Tax (CEO only)
    GetPage(
      name: AppRoutes.holdingTaxStats,
      page: () => const HoldingTaxStatsScreen(),
      binding: HoldingTaxAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),

    // Grievances (CEO + Admin)
    GetPage(
      name: AppRoutes.grievanceList,
      page: () => const GrievanceListScreen(),
      binding: GrievanceAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.grievanceDetail,
      page: () => const GrievanceDetailScreen(),
      binding: GrievanceAdminBinding(),
    ),

    // Billing (CEO only)
    GetPage(
      name: AppRoutes.billingDashboard,
      page: () => const BillingDashboardScreen(),
      binding: BillingAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.generateBills,
      page: () => const GenerateBillsScreen(),
      binding: BillingAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.updatePayment,
      page: () => const UpdatePaymentScreen(),
      binding: BillingAdminBinding(),
    ),

    // Garbage Admin (CEO only)
    GetPage(
      name: AppRoutes.garbageDashboard,
      page: () => const GarbageDashboardScreen(),
      binding: GarbageAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.addTruck,
      page: () => const AddTruckScreen(),
      binding: GarbageAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.assignDriver,
      page: () => const AssignDriverScreen(),
      binding: GarbageAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.createSchedule,
      page: () => const CreateScheduleScreen(),
      binding: GarbageAdminBinding(),
    ),

    // Advertisements (CEO only)
    GetPage(
      name: AppRoutes.adList,
      page: () => const AdListScreen(),
      binding: AdvertisementAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.adCreate,
      page: () => const AdCreateScreen(),
      binding: AdvertisementAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.adDetail,
      page: () => const AdDetailScreen(),
      binding: AdvertisementAdminBinding(),
    ),

    // Notices (CEO + Admin)
    GetPage(
      name: AppRoutes.noticeList,
      page: () => const NoticeListScreen(),
      binding: NoticeAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.noticeCreate,
      page: () => const NoticeCreateScreen(),
      binding: NoticeAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.noticeDetail,
      page: () => const NoticeDetailScreen(),
      binding: NoticeAdminBinding(),
    ),

    // Notifications (CEO + Admin)
    GetPage(
      name: AppRoutes.notificationList,
      page: () => const NotificationListScreen(),
      binding: NotificationAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.broadcastNotification,
      page: () => const BroadcastScreen(),
      binding: NotificationAdminBinding(),
    ),
    GetPage(
      name: AppRoutes.sendToUser,
      page: () => const SendToUserScreen(),
      binding: NotificationAdminBinding(),
    ),

    // Payment History (CEO only)
    GetPage(
      name: AppRoutes.paymentHistory,
      page: () => const PaymentHistoryScreen(),
      binding: PaymentHistoryBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),

    // Pet Dog (CEO only)
    GetPage(
      name: AppRoutes.petDogList,
      page: () => const PetDogListScreen(),
      binding: PetDogAdminBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo']),
      ],
    ),
    GetPage(
      name: AppRoutes.petDogDetail,
      page: () => const PetDogDetailScreen(),
      binding: PetDogAdminBinding(),
    ),

    // User Management (CEO + Admin)
    GetPage(
      name: AppRoutes.userRoleManagement,
      page: () => const UserListScreen(),
      binding: UserManagementBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['ceo', 'admin']),
      ],
    ),
    GetPage(
      name: AppRoutes.createUser,
      page: () => const CreateUserScreen(),
      binding: UserManagementBinding(),
    ),
    GetPage(
      name: AppRoutes.editUser,
      page: () => const EditUserScreen(),
      binding: UserManagementBinding(),
    ),

    // Profile (All roles)
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.adminEditProfile,
      page: () => const EditProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.adminChangePassword,
      page: () => const ChangePasswordScreen(),
      binding: ProfileBinding(),
    ),

    // Driver
    GetPage(
      name: AppRoutes.driverHome,
      page: () => const DriverHomeScreen(),
      binding: GarbageDriverBinding(),
      middlewares: [
        RoleGuard(allowedRoles: ['driver']),
      ],
    ),
    GetPage(
      name: AppRoutes.driverDashboard,
      page: () => DriverView(),
      binding: DriverDashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.driverProfile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
