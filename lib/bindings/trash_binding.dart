import 'package:get/get.dart';
import '../controllers/trash_controller.dart';
import '../core/services/dialog_service.dart';

/// Trash Binding
/// Purpose: Initialize dependencies for trash functionality
class TrashBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService());
    }
    
    // Register TrashController
    Get.lazyPut<TrashController>(() => TrashController());
  }
}
