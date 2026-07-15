import '../models/translation_progress.dart';

abstract class TranslationRepository {
  Future<void> startTranslation(String bookId);
  Future<void> pauseTranslation(String bookId);
  Future<void> resumeTranslation(String bookId);
  Future<void> cancelTranslation(String bookId);
  Future<void> updateProgress(TranslationProgress progress);
  Stream<TranslationProgress> watchProgress(String bookId);
  Future<TranslationProgress?> getProgress(String bookId);
  Future<bool> isTranslating(String bookId);
}
