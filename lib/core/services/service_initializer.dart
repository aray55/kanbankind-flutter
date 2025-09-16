import 'package:get/get.dart';
import 'package:kanbankit/core/services/storage_service.dart';
import 'package:kanbankit/core/services/user_pref_service.dart';
import 'package:kanbankit/controllers/theme_controller.dart';

import 'font_service.dart';

Future<void> initializeServices() async {

  await Get.putAsync(() => StorageService().init());
  Get.put(FontService());
  await Get.putAsync(() => UserPrefService().init());
  Get.put(ThemeController());
}
