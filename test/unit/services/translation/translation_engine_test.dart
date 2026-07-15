import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/services/translation/translation_engine.dart';
import 'package:booklingua/services/translation/translation_cache.dart';
import 'package:booklingua/services/translation/engines/mlkit_engine.dart';
import 'package:booklingua/data/models/book_chunk_model.dart';

void main() {
  group('TranslationCache', () {
    late TranslationCache cache;

    setUp(() {
      cache = TranslationCache();
    });

    test('generateKey produces consistent hashes', () {
      final key1 = cache.generateKey('Hello world', 'en', 'es');
      final key2 = cache.generateKey('Hello world', 'en', 'es');
      expect(key1, key2);
    });

    test('generateKey produces different hashes for different text', () {
      final key1 = cache.generateKey('Hello', 'en', 'es');
      final key2 = cache.generateKey('World', 'en', 'es');
      expect(key1, isNot(key2));
    });

    test('contains returns false for non-existent key', () {
      final key = cache.generateKey('nonexistent', 'en', 'es');
      expect(cache.contains(key), isFalse);
    });

    test('get returns null for non-existent key', () {
      final key = cache.generateKey('nonexistent', 'en', 'es');
      expect(cache.get(key), isNull);
    });
  });

  group('TranslationService', () {
    test('service can be instantiated with engine', () {
      final engine = MLKitTranslationEngine();
      final service = TranslationService(engine);
      expect(service, isNotNull);
    });

    test('translateChunk handles empty text', () async {
      final engine = MLKitTranslationEngine();
      final service = TranslationService(engine);
      final chunk = BookChunkModel(
        id: 'test',
        bookId: 'book1',
        index: 0,
        sourceText: '',
      );

      expect(
        () => service.translateChunk(
          chunk: chunk,
          sourceLanguage: 'en',
          targetLanguage: 'es',
        ),
        returnsNormally,
      );
    });
  });

  group('MLKitTranslationEngine', () {
    late MLKitTranslationEngine engine;

    setUp(() {
      engine = MLKitTranslationEngine();
    });

    test('initial state is not initialized', () {
      expect(engine.isInitialized, isFalse);
    });

    test('initialize sets initialized to true', () async {
      await engine.initialize();
      expect(engine.isInitialized, isTrue);
    });

    test('dispose sets initialized to false', () async {
      await engine.initialize();
      await engine.dispose();
      expect(engine.isInitialized, isFalse);
    });

    test('name returns ML Kit', () {
      expect(engine.name, 'ML Kit');
    });
  });
}
