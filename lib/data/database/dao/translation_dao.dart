import '../../domain/models/translation_progress.dart';
import '../database/tables.dart' as tbl;

class TranslationDao {
  Stream<TranslationProgress> watchProgress(String bookId) {
    return Stream.periodic(const Duration(milliseconds: 500)).asyncMap((_) {
      final progress = getProgress(bookId);
      return progress;
    }).where((p) => p != null).map((p) => p!);
  }

  Future<TranslationProgress?> getProgress(String bookId) async {
    final row = await tbl.TranslationProgressTable.getByBookId(bookId);
    if (row == null) return null;
    return _fromMap(row);
  }

  Future<void> saveProgress(TranslationProgress progress) async {
    await tbl.TranslationProgressTable.upsert(_toMap(progress));
  }

  Future<void> deleteProgress(String bookId) async {
    await tbl.TranslationProgressTable.deleteByBookId(bookId);
  }

  TranslationProgress _fromMap(Map<String, dynamic> map) {
    return TranslationProgress(
      bookId: map[tbl.TranslationProgressTable.bookId] as String,
      totalChunks: map[tbl.TranslationProgressTable.totalChunks] as int,
      completedChunks:
          map[tbl.TranslationProgressTable.completedChunks] as int? ?? 0,
      failedChunks:
          map[tbl.TranslationProgressTable.failedChunks] as int? ?? 0,
      totalWords: map[tbl.TranslationProgressTable.totalWords] as int,
      translatedWords:
          map[tbl.TranslationProgressTable.translatedWords] as int? ?? 0,
      status: _parseStatus(map[tbl.TranslationProgressTable.status] as String),
      startTime: DateTime.parse(
          map[tbl.TranslationProgressTable.startTime] as String),
      pauseTime: map[tbl.TranslationProgressTable.pauseTime] != null
          ? DateTime.parse(map[tbl.TranslationProgressTable.pauseTime] as String)
          : null,
      elapsedSeconds:
          map[tbl.TranslationProgressTable.elapsedSeconds] as int? ?? 0,
    );
  }

  Map<String, dynamic> _toMap(TranslationProgress progress) {
    return {
      tbl.TranslationProgressTable.bookId: progress.bookId,
      tbl.TranslationProgressTable.totalChunks: progress.totalChunks,
      tbl.TranslationProgressTable.completedChunks: progress.completedChunks,
      tbl.TranslationProgressTable.failedChunks: progress.failedChunks,
      tbl.TranslationProgressTable.totalWords: progress.totalWords,
      tbl.TranslationProgressTable.translatedWords: progress.translatedWords,
      tbl.TranslationProgressTable.status: progress.status.name,
      tbl.TranslationProgressTable.startTime:
          progress.startTime.toIso8601String(),
      tbl.TranslationProgressTable.pauseTime:
          progress.pauseTime?.toIso8601String(),
      tbl.TranslationProgressTable.elapsedSeconds: progress.elapsedSeconds,
    };
  }

  TranslationStatus _parseStatus(String status) {
    return TranslationStatus.values.firstWhere((s) => s.name == status);
  }
}
