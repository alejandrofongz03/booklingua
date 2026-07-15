import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/domain/models/translation_progress.dart';
import 'package:booklingua/domain/models/book.dart';

void main() {
  group('TranslationProgress', () {
    test('creates with defaults', () {
      final progress = TranslationProgress(
        bookId: '1',
        totalChunks: 10,
        totalWords: 1000,
        startTime: DateTime.now(),
      );

      expect(progress.completedChunks, 0);
      expect(progress.failedChunks, 0);
      expect(progress.status, TranslationStatus.pending);
      expect(progress.progressPercent, 0);
    });

    test('progressPercent calculates correctly', () {
      final progress = TranslationProgress(
        bookId: '1',
        totalChunks: 10,
        completedChunks: 5,
        totalWords: 1000,
        translatedWords: 500,
        status: TranslationStatus.inProgress,
        startTime: DateTime.now(),
      );

      expect(progress.progressPercent, 0.5);
    });

    test('elapsedFormatted formats correctly', () {
      final progress = TranslationProgress(
        bookId: '1',
        totalChunks: 10,
        totalWords: 1000,
        startTime: DateTime.now(),
        elapsedSeconds: 65,
      );

      expect(progress.elapsedFormatted, '1m 5s');
    });

    test('copyWith creates modified instance', () {
      final progress = TranslationProgress(
        bookId: '1',
        totalChunks: 10,
        totalWords: 1000,
        startTime: DateTime.now(),
      );

      final modified = progress.copyWith(
        completedChunks: 5,
        status: TranslationStatus.paused,
      );

      expect(modified.completedChunks, 5);
      expect(modified.status, TranslationStatus.paused);
      expect(progress.completedChunks, 0);
    });
  });
}
