import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/domain/models/book.dart';

void main() {
  group('Book', () {
    final now = DateTime.now();

    test('creates Book with default values', () {
      final book = Book(
        id: '1',
        title: 'Test Book',
        format: BookFormat.epub,
        filePath: '/path/to/book.epub',
        fileSize: 1024,
        createdAt: now,
      );

      expect(book.id, '1');
      expect(book.title, 'Test Book');
      expect(book.format, BookFormat.epub);
      expect(book.fileSize, 1024);
      expect(book.translationStatus, TranslationStatus.pending);
      expect(book.totalChunks, 0);
      expect(book.translatedChunks, 0);
      expect(book.progressPercent, 0);
    });

    test('copyWith creates modified copy', () {
      final book = Book(
        id: '1',
        title: 'Test Book',
        format: BookFormat.epub,
        filePath: '/path/to/book.epub',
        fileSize: 1024,
        createdAt: now,
      );

      final modified = book.copyWith(
        title: 'Modified Title',
        translationStatus: TranslationStatus.completed,
        translatedChunks: 10,
        totalChunks: 10,
      );

      expect(modified.title, 'Modified Title');
      expect(modified.translationStatus, TranslationStatus.completed);
      expect(modified.translatedChunks, 10);
      expect(modified.progressPercent, 1.0);

      expect(book.title, 'Test Book');
      expect(book.translationStatus, TranslationStatus.pending);
    });

    test('progressPercent calculates correctly', () {
      final book = Book(
        id: '1',
        title: 'Test',
        format: BookFormat.epub,
        filePath: '/path',
        fileSize: 0,
        createdAt: now,
        totalChunks: 4,
        translatedChunks: 2,
      );

      expect(book.progressPercent, 0.5);
    });
  });
}
