import 'package:get/get.dart';
import 'controllers/job_posting_controller.dart';

class JobPostingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => JobPostingController());
  }
}
