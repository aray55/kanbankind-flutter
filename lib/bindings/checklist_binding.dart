import 'package:get/get.dart';
import '../controllers/checklists_controller.dart';
import '../controllers/checklist_item_controller.dart';
import '../core/services/dialog_service.dart';

class ChecklistBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }
    
    // Register ChecklistItemController (for checklist items)
    Get.lazyPut<ChecklistItemController>(() => ChecklistItemController());
    
    // Register ChecklistsController (for checklists)
    Get.lazyPut<ChecklistsController>(() => ChecklistsController());
  }
}
