import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

class SettingsLocalDatasource {
  late Box<String> _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox<String>(AppConstants.settingsBoxName);
  }

  String? get(String key) => _settingsBox.get(key);

  Future<void> set(String key, String value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> delete(String key) async {
    await _settingsBox.delete(key);
  }

  Future<void> clear() async {
    await _settingsBox.clear();
  }
}
