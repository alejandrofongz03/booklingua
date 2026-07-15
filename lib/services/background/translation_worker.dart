import 'dart:async';
import 'dart:isolate';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/book_chunk_model.dart';
import '../translation/translation_engine.dart';
import '../segmentation/text_segmenter.dart';

class TranslationWorker {
  final TranslationEngine _engine;
  final TextSegmenter _segmenter;
  bool _isRunning = false;
  bool _isPaused = false;
  StreamController<WorkerProgress>? _progressController;

  TranslationWorker({
    required TranslationEngine engine,
    required TextSegmenter segmenter,
  })  : _engine = engine,
        _segmenter = segmenter;

  Stream<WorkerProgress> startTranslation({
    required List<BookChunkModel> chunks,
    required String sourceLanguage,
    required String targetLanguage,
    String? quality,
  }) {
    _isRunning = true;
    _isPaused = false;
    _progressController = StreamController<WorkerProgress>.broadcast();

    if (!_engine.isInitialized) {
      _engine.initialize();
    }

    _processChunks(chunks, sourceLanguage, targetLanguage, quality);
    return _progressController!.stream;
  }

  Future<void> _processChunks(
    List<BookChunkModel> chunks,
    String sourceLanguage,
    String targetLanguage,
    String? quality,
  ) async {
    final totalChunks = chunks.length;

    for (int i = 0; i < chunks.length; i++) {
      if (!_isRunning) break;

      while (_isPaused && _isRunning) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (!_isRunning) break;

      final chunk = chunks[i];
      try {
        final startTime = DateTime.now();
        final translatedText = await _engine.translate(
          text: chunk.sourceText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          quality: quality,
        );
        final elapsed = DateTime.now().difference(startTime);

        chunks[i] = chunk.copyWith(
          translatedText: translatedText,
          isTranslated: true,
        );

        _progressController?.add(WorkerProgress(
          completedChunks: i + 1,
          totalChunks: totalChunks,
          currentChunkIndex: i,
          elapsedSeconds: elapsed.inSeconds,
          isCompleted: i == chunks.length - 1,
        ));

        await Future.delayed(AppConstants.progressUpdateInterval);
      } catch (e) {
        AppLogger.error('Error translating chunk ${chunk.index}: $e');
        _progressController?.addError(e);
      }
    }

    _isRunning = false;
    await _progressController?.close();
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  void cancel() {
    _isRunning = false;
    _isPaused = false;
  }

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
}

class WorkerProgress {
  final int completedChunks;
  final int totalChunks;
  final int currentChunkIndex;
  final int elapsedSeconds;
  final bool isCompleted;

  const WorkerProgress({
    required this.completedChunks,
    required this.totalChunks,
    required this.currentChunkIndex,
    this.elapsedSeconds = 0,
    this.isCompleted = false,
  });

  double get progressPercent {
    if (totalChunks == 0) return 0;
    return completedChunks / totalChunks;
  }
}
