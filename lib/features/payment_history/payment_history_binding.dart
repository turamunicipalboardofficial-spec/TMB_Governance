import 'package:get/get.dart';
import 'controllers/payment_history_controller.dart';
import 'data/payment_history_data_source.dart';
import 'repositories/payment_history_repository.dart';

class PaymentHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentHistoryDataSource());
    Get.lazyPut(() => PaymentHistoryRepository(Get.find<PaymentHistoryDataSource>()));
    Get.lazyPut(() => PaymentHistoryController(Get.find<PaymentHistoryRepository>()));
  }
}
