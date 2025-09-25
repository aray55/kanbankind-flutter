import 'package:get/get.dart';

class ExpandableController extends GetxController {
  final RxBool isExpanded = false.obs;

  void toggle() => isExpanded.value = !isExpanded.value;
  void expand() => isExpanded.value = true;
  void collapse() => isExpanded.value = false;
}
