import 'package:get/get.dart';
import 'package:kanbankit/core/services/storage_service.dart';
import 'package:kanbankit/core/constants/storage_keys_costants/user_pref_keys.dart';

class UserPrefService extends GetxService {
  late StorageService _storageService;

  Future<UserPrefService> init() async {
    _storageService = Get.find<StorageService>();
    return this;
  }

  // Save locale
  Future<void> saveLocale(String locale) async {
    await _storageService.write(UserPrefKeys.locale, locale);
  }

  // Get saved locale
  String? getSavedLocale() {
    return _storageService.read(UserPrefKeys.locale);
  }

  // Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _storageService.write(UserPrefKeys.theme, themeMode);
  }

  // Get saved theme mode
  String? getSavedThemeMode() {
    return _storageService.read(UserPrefKeys.theme);
  }
}