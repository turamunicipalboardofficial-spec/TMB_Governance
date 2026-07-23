import 'package:get/get.dart';
import 'controllers/main_shell_controller.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../dashboard/data/dashboard_data_source.dart';
import '../dashboard/repositories/dashboard_repository.dart';
import '../form_approval/controllers/form_approval_controller.dart';
import '../form_approval/data/form_approval_data_source.dart';
import '../form_approval/repositories/form_approval_repository.dart';
import '../job_posting/controllers/job_posting_controller.dart';
import '../profile/controllers/profile_controller.dart';
import '../profile/data/profile_data_source.dart';
import '../profile/repositories/profile_repository.dart';
import '../grievance_admin/controllers/grievance_admin_controller.dart';
import '../grievance_admin/data/grievance_admin_data_source.dart';
import '../grievance_admin/repositories/grievance_admin_repository.dart';
import '../notice_admin/controllers/notice_admin_controller.dart';
import '../notice_admin/data/notice_admin_data_source.dart';
import '../notice_admin/repositories/notice_admin_repository.dart';
import '../notification_admin/controllers/notification_admin_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainShellController());

    // Dashboard (has data source + repository)
    Get.lazyPut(() => DashboardDataSource());
    Get.lazyPut(() => DashboardRepository(Get.find<DashboardDataSource>()));
    Get.lazyPut(() => DashboardController(Get.find<DashboardRepository>()));

    // Form Approval (has data source + repository)
    Get.lazyPut(() => FormApprovalDataSource());
    Get.lazyPut(() => FormApprovalRepository(Get.find<FormApprovalDataSource>()));
    Get.lazyPut(() => FormApprovalController(Get.find<FormApprovalRepository>()));

    // Job Posting (no data source / repository)
    Get.lazyPut(() => JobPostingController());

    // Profile (has data source + repository)
    Get.lazyPut(() => ProfileDataSource());
    Get.lazyPut(() => ProfileRepository(Get.find<ProfileDataSource>()));
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>()));

    // Grievance Admin (has data source + repository)
    Get.lazyPut(() => GrievanceAdminDataSource());
    Get.lazyPut(() => GrievanceAdminRepository(Get.find<GrievanceAdminDataSource>()));
    Get.lazyPut(() => GrievanceAdminController(Get.find<GrievanceAdminRepository>()));

    // Notice Admin (has data source + repository)
    Get.lazyPut(() => NoticeAdminDataSource());
    Get.lazyPut(() => NoticeAdminRepository(Get.find<NoticeAdminDataSource>()));
    Get.lazyPut(() => NoticeAdminController(Get.find<NoticeAdminRepository>()));

    // Notification Admin (no data source / repository)
    Get.lazyPut(() => NotificationAdminController());
  }
}