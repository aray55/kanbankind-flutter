import 'package:get/get.dart';

class FontService extends GetxService {
  // القيمة الحالية
  final currentFont = "Cairo".obs;
  final currentScale = 1.0.obs;

  // تغيير الخط
  void setFont(String font) {
    currentFont.value = font;
  }

  // تغيير حجم النص
  void setScale(double scale) {
    currentScale.value = scale;
  }
  @override
  void onInit() {
    super.onInit();
  }
  @override
  void onReady() {
    super.onReady();
  }
  @override
  void onClose() {
    super.onClose();
  }
  
}
