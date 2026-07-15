import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../data/models/book_chunk_model.dart';
import 'translation_cache.dart';

abstract class TranslationEngine {
  String get name;
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? quality,
  });
  Future<void> initialize();
  Future<void> dispose();
  bool get isInitialized;
}

class TranslationResult {
  final String translatedText;
  final Duration elapsed;
  final bool fromCache;

  const TranslationResult({
    required this.translatedText,
    required this.elapsed,
    this.fromCache = false,
  });
}

class TranslationService {
  final TranslationEngine _engine;
  final TranslationCache _cache;

  TranslationService(this._engine, {TranslationCache? cache})
      : _cache = cache ?? TranslationCache();

  Future<TranslationResult> translateChunk({
    required BookChunkModel chunk,
    required String sourceLanguage,
    required String targetLanguage,
    String? quality,
  }) async {
    final startTime = DateTime.now();

    final cacheKey = _cache.generateKey(
      chunk.sourceText,
      sourceLanguage,
      targetLanguage,
    );

    final cachedText = _cache.get(cacheKey);
    if (cachedText != null) {
      AppLogger.debug('Cache hit for chunk ${chunk.index}');
      return TranslationResult(
        translatedText: cachedText,
        elapsed: Duration.zero,
        fromCache: true,
      );
    }

    try {
      final translated = await _engine.translate(
        text: chunk.sourceText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        quality: quality,
      );

      _cache.set(cacheKey, translated);

      final elapsed = DateTime.now().difference(startTime);
      return TranslationResult(translatedText: translated, elapsed: elapsed);
    } catch (e) {
      AppLogger.error('Translation error for chunk ${chunk.index}: $e');
      throw TranslationFailure(message: 'Translation error: $e');
    }
  }
}
