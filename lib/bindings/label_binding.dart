import 'package:get/get.dart';
import '../controllers/label_controller.dart';
import '../controllers/card_label_controller.dart';

class LabelBinding extends Bindings {
  @override
  void dependencies() {
    // Register LabelController
    Get.lazyPut<LabelController>(
      () => LabelController(),
      fenix: true,
    );

    // Register CardLabelController
    Get.lazyPut<CardLabelController>(
      () => CardLabelController(),
      fenix: true,
    );
  }
}
