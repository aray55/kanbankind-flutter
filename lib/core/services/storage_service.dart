import 'package:get_storage/get_storage.dart';

class StorageService {
  late GetStorage _box;

  Future<StorageService> init() async {
    _box = GetStorage();
    await _box.initStorage;
    return this;
  }

  // Write data
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  // Read data
  dynamic read(String key) {
    return _box.read(key);
  }

  // Remove data
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _box.erase();
  }
}
