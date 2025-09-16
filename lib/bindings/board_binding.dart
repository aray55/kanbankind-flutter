import 'package:get/get.dart';
import '../controllers/board_controller.dart';
import '../controllers/checklist_controller.dart';
import '../controllers/task_editor_controller.dart';
import '../core/services/dialog_service.dart' show DialogService;

class BoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoardController>(() => BoardController());
    Get.lazyPut<ChecklistController>(() => ChecklistController());
    Get.put<DialogService>(DialogService(), permanent: true);
    Get.put<TaskEditorController>(TaskEditorController());
  
  }
}
