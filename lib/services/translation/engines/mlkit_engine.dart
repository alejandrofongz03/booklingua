import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../../core/utils/logger.dart';
import 'translation_engine.dart';
import 'translation_cache.dart';

class MLKitTranslationEngine extends TranslationEngine {
  final TranslationCache _cache;
  OnDeviceTranslator? _translator;
  bool _initialized = false;
  String? _currentSourceLanguage;
  String? _currentTargetLanguage;

  MLKitTranslationEngine({TranslationCache? cache})
      : _cache = cache ?? TranslationCache();

  @override
  String get name => 'ML Kit';

  @override
  Future<void> initialize() async {
    _initialized = true;
    AppLogger.info('ML Kit Translation Engine initialized');
  }

  @override
  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
    _initialized = false;
    AppLogger.info('ML Kit Translation Engine disposed');
  }

  @override
  bool get isInitialized => _initialized;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? quality,
  }) async {
    if (text.trim().isEmpty) return '';

    if (_translator == null ||
        _currentSourceLanguage != sourceLanguage ||
        _currentTargetLanguage != targetLanguage) {
      await _createTranslator(sourceLanguage, targetLanguage);
    }

    if (text.length <= 5000) {
      return _translateWithCache(text, sourceLanguage, targetLanguage);
    }

    final chunks = _splitText(text, 5000);
    final results = <String>[];
    for (final chunk in chunks) {
      final result = await _translateWithCache(chunk, sourceLanguage, targetLanguage);
      results.add(result);
    }
    return results.join(' ');
  }

  Future<String> _translateWithCache(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final cacheKey = _cache.generateKey(text, sourceLanguage, targetLanguage);
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;

    final translated = await _translator!.translateText(text);
    _cache.set(cacheKey, translated);
    return translated;
  }

  Future<void> _createTranslator(
    String sourceLanguage,
    String targetLanguage,
  ) async {
    await _translator?.close();

    final source = _parseLanguage(sourceLanguage);
    final target = _parseLanguage(targetLanguage);

    _translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
      options: OnDeviceTranslatorOptions(),
    );

    _currentSourceLanguage = sourceLanguage;
    _currentTargetLanguage = targetLanguage;
    AppLogger.info('ML Kit translator created: $sourceLanguage -> $targetLanguage');
  }

  TranslateLanguage _parseLanguage(String code) {
    switch (code.toLowerCase()) {
      case 'en': return TranslateLanguage.english;
      case 'es': return TranslateLanguage.spanish;
      case 'fr': return TranslateLanguage.french;
      case 'de': return TranslateLanguage.german;
      case 'it': return TranslateLanguage.italian;
      case 'pt': return TranslateLanguage.portuguese;
      case 'ru': return TranslateLanguage.russian;
      case 'ja': return TranslateLanguage.japanese;
      case 'ko': return TranslateLanguage.korean;
      case 'zh': return TranslateLanguage.chinese;
      case 'ar': return TranslateLanguage.arabic;
      case 'hi': return TranslateLanguage.hindi;
      default:
        AppLogger.warning('Unknown language code: $code, defaulting to English');
        return TranslateLanguage.english;
    }
  }

  List<String> _splitText(String text, int maxLength) {
    final chunks = <String>[];
    int start = 0;

    while (start < text.length) {
      int end = start + maxLength;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      int breakPoint = text.lastIndexOf('. ', end);
      if (breakPoint <= start || breakPoint < end - 500) {
        breakPoint = text.lastIndexOf(' ', end);
      }
      if (breakPoint <= start || breakPoint < end - 500) {
        breakPoint = end;
      } else {
        breakPoint++;
      }

      chunks.add(text.substring(start, breakPoint));
      start = breakPoint;
    }

    return chunks;
  }
}
