import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../data/datasources/local/translation_cache_datasource.dart';
import '../../data/models/translation_cache_model.dart';

class TranslationCache {
  TranslationCacheDatasource? _datasource;
  bool _initialized = false;

  TranslationCache({TranslationCacheDatasource? datasource}) {
    _datasource = datasource;
    _initialized = datasource != null;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _datasource = TranslationCacheDatasource();
      await _datasource!.init();
      _initialized = true;
    }
  }

  String generateKey(String text, String sourceLanguage, String targetLanguage) {
    final input = '$sourceLanguage:$targetLanguage:$text';
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  String? get(String key) {
    if (_datasource == null) return null;
    return _datasource!.get(key);
  }

  Future<void> set(String key, String translatedText) async {
    await _ensureInitialized();
    await _datasource!.set(
      TranslationCacheModel(
        sourceHash: key,
        sourceText: '',
        translatedText: translatedText,
        sourceLanguage: '',
        targetLanguage: '',
        cachedAt: DateTime.now(),
      ),
    );
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _datasource!.clear();
  }

  int get size => _datasource?.size ?? 0;

  bool contains(String key) => get(key) != null;
}
