import 'package:get/get.dart';
import '../controllers/checklist_controller.dart';
import '../core/services/dialog_service.dart';

class ChecklistBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }
    // Register ChecklistController
    Get.lazyPut<ChecklistController>(() => ChecklistController());

  }
}
