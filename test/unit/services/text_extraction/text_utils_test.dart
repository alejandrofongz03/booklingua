import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/core/utils/text_utils.dart';

void main() {
  group('TextUtils', () {
    test('countWords returns correct count', () {
      expect(TextUtils.countWords('Hello world'), 2);
      expect(TextUtils.countWords(''), 0);
      expect(TextUtils.countWords('   '), 0);
      expect(TextUtils.countWords('One two three four'), 4);
    });

    test('countCharacters returns correct count', () {
      expect(TextUtils.countCharacters('Hello'), 5);
      expect(TextUtils.countCharacters(''), 0);
    });

    test('splitIntoChunks splits text correctly', () {
      final text = 'A' * 10000;
      final chunks = TextUtils.splitIntoChunks(text, 5000);
      expect(chunks.length, greaterThanOrEqualTo(2));
      expect(chunks.first.length, lessThanOrEqualTo(5000));
    });

    test('splitIntoChunks returns single chunk for small text', () {
      final text = 'Short text';
      final chunks = TextUtils.splitIntoChunks(text, 5000);
      expect(chunks.length, 1);
      expect(chunks.first, text);
    });

    test('detectLanguage returns en for English text', () {
      final text = 'This is a simple English sentence for testing';
      expect(TextUtils.detectLanguage(text), 'en');
    });

    test('estimateReadingTimeMinutes returns positive value', () {
      final text = 'word ' * 200;
      final time = TextUtils.estimateReadingTimeMinutes(text);
      expect(time, greaterThan(0));
    });
  });
}
