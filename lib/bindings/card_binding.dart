import 'package:get/get.dart';
import '../controllers/card_controller.dart';
import '../controllers/checklists_controller.dart';
import '../controllers/comment_controller.dart';
import '../controllers/attachment_controller.dart';
import '../controllers/activity_log_controller.dart';
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
    
    // Register CommentController (for card comments)
    Get.lazyPut<CommentController>(() => CommentController());
    
    // Register AttachmentController (for card attachments)
    Get.lazyPut<AttachmentController>(() => AttachmentController());
    
    // Register ActivityLogController (for activity tracking)
    Get.lazyPut<ActivityLogController>(() => ActivityLogController());
  }
}
