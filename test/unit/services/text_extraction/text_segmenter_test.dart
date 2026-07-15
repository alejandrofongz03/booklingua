import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/services/segmentation/text_segmenter.dart';

void main() {
  group('TextSegmenter', () {
    late TextSegmenter segmenter;

    setUp(() {
      segmenter = TextSegmenter(maxChunkSize: 100);
    });

    test('segment splits text into chunks', () {
      final text = 'A' * 250;
      final chunks = segmenter.segment(bookId: 'book1', text: text);

      expect(chunks.length, greaterThan(1));
      expect(chunks.every((c) => c.bookId == 'book1'), isTrue);
      expect(chunks.first.index, 0);
      expect(chunks.last.index, chunks.length - 1);
    });

    test('segment returns single chunk for small text', () {
      final text = 'Short text';
      final chunks = segmenter.segment(bookId: 'book1', text: text);

      expect(chunks.length, 1);
      expect(chunks.first.sourceText, 'Short text');
    });

    test('reassemble combines chunks in order', () {
      final chunks = segmenter.segment(bookId: 'book1', text: 'Part1\n\nPart2\n\nPart3');
      final reassembled = segmenter.reassemble(chunks);

      expect(reassembled.contains('Part1'), isTrue);
      expect(reassembled.contains('Part2'), isTrue);
      expect(reassembled.contains('Part3'), isTrue);
    });

    test('getPendingChunks returns untranslated chunks', () {
      final chunks = segmenter.segment(bookId: 'book1', text: 'A' * 250);
      final pending = segmenter.getPendingChunks(chunks);

      expect(pending.length, chunks.length);
    });
  });
}
