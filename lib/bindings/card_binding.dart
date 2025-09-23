import 'package:get/get.dart';
import '../controllers/card_controller.dart';
import '../controllers/checklists_controller.dart';
import '../core/services/dialog_service.dart';

class CardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }
    
    // Register CardController
    Get.lazyPut<CardController>(() => CardController());
    
    // Register ChecklistsController (needed for card checklist functionality)
    Get.lazyPut<ChecklistsController>(() => ChecklistsController());
  }
}
