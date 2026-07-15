import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/translation_cache_model.dart';

class TranslationCacheDatasource {
  late Box<String> _cacheBox;

  Future<void> init() async {
    _cacheBox = await Hive.openBox<String>(AppConstants.cacheBoxName);
  }

  String? get(String sourceHash) {
    final entry = _cacheBox.get(sourceHash);
    if (entry == null) return null;
    try {
      final model = TranslationCacheModel.fromJson(
        jsonDecode(entry) as Map<String, dynamic>,
      );
      return model.translatedText;
    } catch (_) {
      return null;
    }
  }

  Future<void> set(TranslationCacheModel model) async {
    if (_cacheBox.length >= AppConstants.cacheMaxEntries) {
      await _evictOldest();
    }
    await _cacheBox.put(model.sourceHash, jsonEncode(model.toJson()));
  }

  Future<void> clear() async {
    await _cacheBox.clear();
  }

  Future<void> _evictOldest() async {
    if (_cacheBox.isEmpty) return;
    final oldestKey = _cacheBox.keys.first;
    await _cacheBox.delete(oldestKey);
  }

  int get size => _cacheBox.length;
}
