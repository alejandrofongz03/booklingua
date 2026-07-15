import '../../domain/models/translation_progress.dart';
import '../../domain/repositories/translation_repository.dart';
import '../database/dao/translation_dao.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationDao _translationDao;

  TranslationRepositoryImpl(this._translationDao);

  @override
  Future<void> startTranslation(String bookId) async {
    final progress = TranslationProgress(
      bookId: bookId,
      totalChunks: 0,
      totalWords: 0,
      status: TranslationStatus.inProgress,
      startTime: DateTime.now(),
    );
    await _translationDao.saveProgress(progress);
  }

  @override
  Future<void> pauseTranslation(String bookId) async {
    final current = await _translationDao.getProgress(bookId);
    if (current != null) {
      await _translationDao.saveProgress(
        current.copyWith(
          status: TranslationStatus.paused,
          pauseTime: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> resumeTranslation(String bookId) async {
    final current = await _translationDao.getProgress(bookId);
    if (current != null) {
      await _translationDao.saveProgress(
        current.copyWith(
          status: TranslationStatus.inProgress,
          pauseTime: null,
        ),
      );
    }
  }

  @override
  Future<void> cancelTranslation(String bookId) async {
    await _translationDao.deleteProgress(bookId);
  }

  @override
  Future<void> updateProgress(TranslationProgress progress) async {
    await _translationDao.saveProgress(progress);
  }

  @override
  Stream<TranslationProgress> watchProgress(String bookId) {
    return _translationDao.watchProgress(bookId);
  }

  @override
  Future<TranslationProgress?> getProgress(String bookId) async {
    return _translationDao.getProgress(bookId);
  }

  @override
  Future<bool> isTranslating(String bookId) async {
    final progress = await _translationDao.getProgress(bookId);
    return progress?.status == TranslationStatus.inProgress;
  }
}
