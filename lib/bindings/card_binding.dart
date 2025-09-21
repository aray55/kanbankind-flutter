import 'package:get/get.dart';
import '../controllers/card_controller.dart';
import '../core/services/dialog_service.dart';

class CardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure DialogService is available
    if (!Get.isRegistered<DialogService>()) {
      Get.put<DialogService>(DialogService(), permanent: true);
    }
    Get.lazyPut<CardController>(() => CardController());
  }
}