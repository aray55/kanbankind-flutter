import 'package:get/get.dart';
import '../controllers/list_controller.dart';
import '../controllers/board_controller.dart';
import '../core/services/dialog_service.dart';

class ListBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }

    // Ensure BoardController is available (needed for board context)
    if (!Get.isRegistered<BoardController>()) {
      Get.lazyPut<BoardController>(() => BoardController());
    }

    // Register ListController
    Get.lazyPut<ListController>(() => ListController());
  }
}
