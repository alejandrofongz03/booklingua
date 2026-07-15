import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/core/utils/text_utils.dart';
import 'package:booklingua/services/segmentation/text_segmenter.dart';
import 'package:booklingua/services/translation/translation_cache.dart';
import 'package:booklingua/services/format_preserver/format_preserver.dart';

void main() {
  group('Integration: Core Services', () {
    test('TextUtils + TextSegmenter work together', () {
      final text = 'Hello world. This is a test. ' * 100;
      final wordCount = TextUtils.countWords(text);
      expect(wordCount, greaterThan(0));

      final segmenter = TextSegmenter(maxChunkSize: 500);
      final chunks = segmenter.segment(bookId: 'test', text: text);
      expect(chunks.length, greaterThan(1));

      final reassembled = segmenter.reassemble(chunks);
      final reassembledWords = TextUtils.countWords(reassembled);
      expect(reassembledWords, wordCount);
    });

    test('FormatPreserver extracts metadata', () {
      final preserver = FormatPreserver();
      final text = '# Chapter 1\n\nThis is **bold** and *italic* text.';
      final metadata = preserver.extractMetadata(text);

      expect(metadata['hasHeadings'], isTrue);
      expect(metadata['hasBold'], isTrue);
      expect(metadata['hasItalic'], isTrue);
    });

    test('TranslationCache generates consistent keys', () {
      final cache = TranslationCache();
      final key1 = cache.generateKey('Hello', 'en', 'es');
      final key2 = cache.generateKey('Hello', 'en', 'es');
      final key3 = cache.generateKey('Hello', 'en', 'fr');

      expect(key1, key2);
      expect(key1, isNot(key3));
    });
  });
}
