// import 'package:get/get.dart';
// import '../controllers/task_controller.dart';
// import '../controllers/checklist_controller.dart';
// import '../controllers/task_editor_controller.dart';
// import '../core/services/dialog_service.dart' show DialogService;

// class TaskBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Ensure DialogService is available
//     if (!Get.isRegistered<DialogService>()) {
//       Get.put<DialogService>(DialogService(), permanent: true);
//     }

//     // Register Task-related controllers
//     Get.lazyPut<TaskController>(() => TaskController());
//     Get.lazyPut<ChecklistController>(() => ChecklistController());
//     Get.lazyPut<TaskEditorController>(() => TaskEditorController());
//   }
// }
