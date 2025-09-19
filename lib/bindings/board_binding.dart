import 'package:get/get.dart';
import '../controllers/board_controller.dart';
import '../core/services/dialog_service.dart';

class BoardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }

    // Register BoardController
    Get.lazyPut<BoardController>(() => BoardController());
  }
}
