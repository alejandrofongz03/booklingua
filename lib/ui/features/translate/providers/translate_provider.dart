import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../di/injection_container.dart';
import '../../../../services/background/book_translation_orchestrator.dart';
import '../../../../services/file_export/file_export_service.dart';

enum TranslateStep { selectFile, configuring, translating, completed, error }

class TranslateState {
  final TranslateStep step;
  final String? filePath;
  final String? fileName;
  final String? fileFormat;
  final int? fileSize;
  final String sourceLanguage;
  final String targetLanguage;
  final OrchestratorProgress? progress;
  final bool isPaused;
  final String? error;

  final String? exportPath;
  final bool isExporting;
  final String? exportError;

  const TranslateState({
    this.step = TranslateStep.selectFile,
    this.filePath,
    this.fileName,
    this.fileFormat,
    this.fileSize,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'es',
    this.progress,
    this.isPaused = false,
    this.error,
    this.exportPath,
    this.isExporting = false,
    this.exportError,
  });

  TranslateState copyWith({
    TranslateStep? step,
    String? filePath,
    String? fileName,
    String? fileFormat,
    int? fileSize,
    String? sourceLanguage,
    String? targetLanguage,
    OrchestratorProgress? progress,
    bool? isPaused,
    String? error,
    bool clearError = false,
    String? exportPath,
    bool? isExporting,
    String? exportError,
    bool clearExportError = false,
  }) {
    return TranslateState(
      step: step ?? this.step,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSize: fileSize ?? this.fileSize,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      progress: progress ?? this.progress,
      isPaused: isPaused ?? this.isPaused,
      error: clearError ? null : (error ?? this.error),
      exportPath: exportPath ?? this.exportPath,
      isExporting: isExporting ?? this.isExporting,
      exportError: clearExportError ? null : (exportError ?? this.exportError),
    );
  }
}

class TranslateNotifier extends StateNotifier<TranslateState> {
  final BookTranslationOrchestrator _orchestrator;
  final FileExportServiceFactory _exportFactory;
  StreamSubscription<OrchestratorProgress>? _progressSubscription;

  TranslateNotifier(this._orchestrator, this._exportFactory)
      : super(const TranslateState()) {
    _listenToProgress();
  }

  void _listenToProgress() {
    _progressSubscription = _orchestrator.progressStream.listen(
      (progress) {
        final isPaused = progress.status == OrchestratorStatus.paused;
        final step = switch (progress.status) {
          OrchestratorStatus.idle => TranslateStep.selectFile,
          OrchestratorStatus.importing ||
          OrchestratorStatus.translating =>
            TranslateStep.translating,
          OrchestratorStatus.paused => TranslateStep.translating,
          OrchestratorStatus.completed => TranslateStep.completed,
          OrchestratorStatus.error => TranslateStep.error,
        };

        state = state.copyWith(
          step: step,
          progress: progress,
          isPaused: isPaused,
          error: progress.error,
          exportPath: progress.status == OrchestratorStatus.completed
              ? _orchestrator.getLastExportPath()
              : state.exportPath,
        );
      },
      onError: (error) {
        AppLogger.error('Translation stream error: $error');
        state = state.copyWith(
          step: TranslateStep.error,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> selectFile({
    required String filePath,
    required String fileName,
    required String fileFormat,
    required int fileSize,
  }) async {
    state = state.copyWith(
      step: TranslateStep.configuring,
      filePath: filePath,
      fileName: fileName,
      fileFormat: fileFormat,
      fileSize: fileSize,
    );
  }

  void clearFile() {
    state = const TranslateState();
  }

  void setSourceLanguage(String language) {
    state = state.copyWith(sourceLanguage: language);
  }

  void setTargetLanguage(String language) {
    state = state.copyWith(targetLanguage: language);
  }

  Future<void> startTranslation() async {
    final filePath = state.filePath;
    if (filePath == null) return;

    try {
      final book = await _orchestrator.importBook(filePath);
      await _orchestrator.startTranslation(book.id);
    } catch (e, st) {
      AppLogger.error('Failed to start translation', error: e, stackTrace: st);
      state = state.copyWith(
        step: TranslateStep.error,
        error: 'Error al iniciar traducción: $e',
      );
    }
  }

  void pauseTranslation() {
    _orchestrator.pauseTranslation();
    state = state.copyWith(isPaused: true);
  }

  void resumeTranslation() {
    _orchestrator.resumeTranslation();
    state = state.copyWith(isPaused: false);
  }

  void cancelTranslation() {
    _orchestrator.cancelTranslation();
    state = const TranslateState();
  }

  void resetError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> exportBook(String format) async {
    final translatedText = _orchestrator.getTranslatedText();
    if (state.filePath == null || translatedText == null) return;

    state = state.copyWith(isExporting: true, clearExportError: true);

    try {
      final exporter = _exportFactory.getExporter(format);
      final outputDir = await _orchestrator.getExportDirectory();
      final outputPath = await exporter.export(
        title: state.fileName ?? 'book',
        author: null,
        translatedText: translatedText,
        outputDir: outputDir,
        originalMetadata: null,
      );

      state = state.copyWith(
        isExporting: false,
        exportPath: outputPath,
      );

      AppLogger.info('Book exported to: $outputPath');
    } catch (e, st) {
      AppLogger.error('Export failed', error: e, stackTrace: st);
      state = state.copyWith(
        isExporting: false,
        exportError: 'Error al exportar: $e',
      );
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _orchestrator.dispose();
    super.dispose();
  }
}

final translateProvider =
    StateNotifierProvider<TranslateNotifier, TranslateState>((ref) {
  final orchestrator = sl<BookTranslationOrchestrator>();
  final exportFactory = sl<FileExportServiceFactory>();
  return TranslateNotifier(orchestrator, exportFactory);
});
