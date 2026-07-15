import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../core/utils/logger.dart';
import '../../data/database/dao/book_dao.dart';
import '../../data/database/dao/translation_dao.dart';
import '../../data/models/book_chunk_model.dart';
import '../../domain/models/book.dart';
import '../../domain/models/translation_progress.dart';
import '../file_import/file_import_service.dart';
import '../file_export/file_export_service.dart';
import '../segmentation/text_segmenter.dart';
import '../translation/translation_engine.dart';
import '../format_preserver/format_preserver.dart';
import 'translation_worker.dart';
import '../notifications/notification_service.dart';

enum OrchestratorStatus { idle, importing, translating, paused, completed, error }

class BookTranslationOrchestrator {
  final BookDao _bookDao;
  final TranslationDao _translationDao;
  final FileImportServiceFactory _importFactory;
  final FileExportServiceFactory _exportFactory;
  final TextSegmenter _segmenter;
  final TranslationEngine _engine;
  final FormatPreserver _formatPreserver;
  final TranslationWorker _worker;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();
  final StreamController<OrchestratorProgress> _progressController =
      StreamController<OrchestratorProgress>.broadcast();

  OrchestratorStatus _status = OrchestratorStatus.idle;
  String? _currentBookId;
  String? _translatedText;
  String? _lastExportPath;

  OrchestratorStatus get status => _status;
  Stream<OrchestratorProgress> get progressStream => _progressController.stream;

  BookTranslationOrchestrator({
    required BookDao bookDao,
    required TranslationDao translationDao,
    required FileImportServiceFactory importFactory,
    required FileExportServiceFactory exportFactory,
    required TextSegmenter segmenter,
    required TranslationEngine engine,
    required FormatPreserver formatPreserver,
    required TranslationWorker worker,
    required NotificationService notificationService,
  })  : _notificationService = notificationService,
        _bookDao = bookDao,
        _translationDao = translationDao,
        _importFactory = importFactory,
        _exportFactory = exportFactory,
        _segmenter = segmenter,
        _engine = engine,
        _formatPreserver = formatPreserver,
        _worker = worker;

  Future<Book> importBook(String filePath) async {
    _status = OrchestratorStatus.importing;
    _emitProgress(step: 'Importando libro...', progress: 0);
    AppLogger.info('Importing book: $filePath');

    final imported = await _importFactory.import(filePath);
    final wordCount = TextUtils.countWords(imported.rawText);
    final chunks = _segmenter.segment(
      bookId: imported.title,
      text: imported.rawText,
    );

    final fileSize = await FileUtils.getFileSize(filePath);
    final book = Book(
      id: _uuid.v4(),
      title: imported.title,
      author: imported.author,
      format: imported.format,
      filePath: filePath,
      coverImagePath: imported.coverImagePath,
      fileSize: fileSize,
      totalChunks: chunks.length,
      totalWords: wordCount,
      createdAt: DateTime.now(),
    );

    final saved = await _bookDao.save(book);
    _currentBookId = saved.id;
    AppLogger.info('Book imported: ${book.title} (${chunks.length} chunks)');
    return saved;
  }

  Future<void> startTranslation(String bookId) async {
    _status = OrchestratorStatus.translating;
    _currentBookId = bookId;
    AppLogger.info('Starting translation for book: $bookId');

    final book = await _bookDao.getById(bookId);
    if (book == null) throw Exception('Book not found');

    final text = await _extractText(book.filePath);
    final chunks = _segmenter.segment(bookId: bookId, text: text);

    await _translationDao.saveProgress(TranslationProgress(
      bookId: bookId,
      totalChunks: chunks.length,
      totalWords: book.totalWords,
      status: TranslationStatus.inProgress,
      startTime: DateTime.now(),
    ));

    await _bookDao.update(book.copyWith(
      translationStatus: TranslationStatus.inProgress,
    ));

    _worker.startTranslation(
      chunks: chunks,
      sourceLanguage: book.sourceLanguage,
      targetLanguage: book.targetLanguage,
      quality: 'high',
    ).listen(
      (progress) {
        final translatedWords = _estimateTranslatedWords(
          chunks, progress.completedChunks);
        _translationDao.saveProgress(TranslationProgress(
          bookId: bookId,
          totalChunks: progress.totalChunks,
          completedChunks: progress.completedChunks,
          totalWords: book.totalWords,
          translatedWords: translatedWords,
          status: TranslationStatus.inProgress,
          startTime: DateTime.now(),
          elapsedSeconds: progress.elapsedSeconds,
          estimatedRemainingSeconds: _estimateRemaining(
            progress.elapsedSeconds,
            progress.completedChunks,
            progress.totalChunks,
          ),
        ));
        _emitProgress(
          step: 'Traduciendo...',
          progress: progress.progressPercent,
          completedChunks: progress.completedChunks,
          totalChunks: progress.totalChunks,
          translatedWords: translatedWords,
          totalWords: book.totalWords,
          elapsedSeconds: progress.elapsedSeconds,
        );
      },
      onError: (error) {
        _status = OrchestratorStatus.error;
        AppLogger.error('Translation error: $error');
        _bookDao.update(book.copyWith(
          translationStatus: TranslationStatus.error,
        ));
        _emitProgress(
          step: 'Error en traducción',
          error: error.toString(),
        );
        _notificationService.showTranslationError(
          bookName: book.title,
          error: error.toString(),
        );
      },
      onDone: () async {
        await _onTranslationComplete(bookId, book, chunks);
      },
    );
  }

  Future<String> _extractText(String filePath) async {
    final imported = await _importFactory.import(filePath);
    return imported.rawText;
  }

  int _estimateTranslatedWords(
    List<BookChunkModel> chunks, int completed) {
    int total = 0;
    for (int i = 0; i < completed && i < chunks.length; i++) {
      total += TextUtils.countWords(chunks[i].sourceText);
    }
    return total;
  }

  int _estimateRemaining(int elapsed, int completed, int total) {
    if (completed == 0) return 0;
    final perChunk = elapsed / completed;
    return (perChunk * (total - completed)).round();
  }

  Future<void> _onTranslationComplete(
    String bookId,
    Book book,
    List<BookChunkModel> chunks,
  ) async {
    _status = OrchestratorStatus.completed;
    _translatedText = _segmenter.reassemble(chunks);
    final outputDir = await _getOutputDir();

    final exporter = _exportFactory.getExporter(book.format.name);
    _lastExportPath = await exporter.export(
      title: book.title,
      author: book.author,
      translatedText: _translatedText!,
      outputDir: outputDir,
      originalMetadata: null,
    );

    await _bookDao.update(book.copyWith(
      translationStatus: TranslationStatus.completed,
      translatedChunks: chunks.length,
      translatedWords: book.totalWords,
      outputPath: _lastExportPath,
      updatedAt: DateTime.now(),
    ));

    _emitProgress(
      step: '¡Traducción completada!',
      progress: 1.0,
      completedChunks: chunks.length,
      totalChunks: chunks.length,
      translatedWords: book.totalWords,
      totalWords: book.totalWords,
    );

    _notificationService.showTranslationComplete(
      title: 'Traducción completada',
      bookName: book.title,
      filePath: _lastExportPath,
    );
    AppLogger.info('Translation completed: $outputPath');
  }

  Future<String> _getOutputDir() async {
    final dir = Directory(
      '${Platform.environment['TEMP'] ?? '/tmp'}${Platform.pathSeparator}booklingua_exports',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  void pauseTranslation() {
    if (_currentBookId == null) return;
    _status = OrchestratorStatus.paused;
    _worker.pause();
    _emitProgress(step: 'Traducción pausada');
  }

  void resumeTranslation() {
    _status = OrchestratorStatus.translating;
    _worker.resume();
    _emitProgress(step: 'Reanudando traducción...');
  }

  void cancelTranslation() {
    _status = OrchestratorStatus.idle;
    _worker.cancel();
    if (_currentBookId != null) {
      _translationDao.deleteProgress(_currentBookId!);
      _bookDao.getById(_currentBookId!).then((book) {
        if (book != null) {
          _bookDao.update(book.copyWith(
            translationStatus: TranslationStatus.cancelled,
            updatedAt: DateTime.now(),
          ));
        }
      });
    }
    _currentBookId = null;
    _emitProgress(step: 'Traducción cancelada', progress: 0);
  }

  String? getTranslatedText() => _translatedText;
  String? getLastExportPath() => _lastExportPath;

  Future<String> getExportDirectory() => _getOutputDir();

  void _emitProgress({
    required String step,
    double progress = 0,
    int completedChunks = 0,
    int totalChunks = 0,
    int translatedWords = 0,
    int totalWords = 0,
    int elapsedSeconds = 0,
    String? error,
  }) {
    _progressController.add(OrchestratorProgress(
      step: step,
      progress: progress,
      completedChunks: completedChunks,
      totalChunks: totalChunks,
      translatedWords: translatedWords,
      totalWords: totalWords,
      elapsedSeconds: elapsedSeconds,
      error: error,
      status: _status,
    ));
  }

  void dispose() {
    _progressController.close();
    _worker.cancel();
  }
}

class OrchestratorProgress {
  final String step;
  final double progress;
  final int completedChunks;
  final int totalChunks;
  final int translatedWords;
  final int totalWords;
  final int elapsedSeconds;
  final String? error;
  final OrchestratorStatus status;

  const OrchestratorProgress({
    required this.step,
    this.progress = 0,
    this.completedChunks = 0,
    this.totalChunks = 0,
    this.translatedWords = 0,
    this.totalWords = 0,
    this.elapsedSeconds = 0,
    this.error,
    this.status = OrchestratorStatus.idle,
  });
}
