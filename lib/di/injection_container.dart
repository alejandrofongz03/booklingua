import 'package:get_it/get_it.dart';
import '../core/utils/logger.dart';
import '../data/database/app_database.dart';
import '../data/database/dao/book_dao.dart';
import '../data/database/dao/translation_dao.dart';
import '../data/datasources/local/settings_local_datasource.dart';
import '../data/datasources/local/translation_cache_datasource.dart';
import '../data/repositories/book_repository_impl.dart';
import '../data/repositories/translation_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/repositories/book_repository.dart';
import '../domain/repositories/translation_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/import_book_usecase.dart';
import '../domain/usecases/get_library_usecase.dart';
import '../domain/usecases/translate_book_usecase.dart';
import '../domain/usecases/pause_translation_usecase.dart';
import '../domain/usecases/resume_translation_usecase.dart';
import '../domain/usecases/cancel_translation_usecase.dart';
import '../domain/usecases/export_book_usecase.dart';
import '../domain/usecases/get_history_usecase.dart';
import '../services/file_import/file_import_service.dart';
import '../services/file_import/epub_import_service.dart';
import '../services/file_import/pdf_import_service.dart';
import '../services/file_import/docx_import_service.dart';
import '../services/file_import/txt_import_service.dart';
import '../services/file_export/file_export_service.dart';
import '../services/file_export/epub_export_service.dart';
import '../services/file_export/pdf_export_service.dart';
import '../services/file_export/docx_export_service.dart';
import '../services/file_export/txt_export_service.dart';
import '../services/translation/translation_engine.dart';
import '../services/translation/translation_cache.dart';
import '../services/translation/engines/mlkit_engine.dart';
import '../services/segmentation/text_segmenter.dart';
import '../services/format_preserver/format_preserver.dart';
import '../services/background/translation_worker.dart';
import '../services/background/book_translation_orchestrator.dart';
import '../services/notifications/notification_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  AppLogger.info('Initializing dependencies...');

  await _initDatabase();
  await _initCache();
  _initDaos();
  _initRepositories();
  _initUseCases();
  _initServices();

  AppLogger.info('Dependencies initialized successfully');
}

Future<void> _initDatabase() async {
  await AppDatabase.database;
}

Future<void> _initCache() async {
  final translationCache = TranslationCacheDatasource();
  await translationCache.init();
  sl.registerLazySingleton<TranslationCacheDatasource>(() => translationCache);

  final settingsCache = SettingsLocalDatasource();
  await settingsCache.init();
  sl.registerLazySingleton<SettingsLocalDatasource>(() => settingsCache);
}

void _initDaos() {
  sl.registerLazySingleton<BookDao>(() => BookDao());
  sl.registerLazySingleton<TranslationDao>(() => TranslationDao());
}

void _initRepositories() {
  sl.registerLazySingleton<BookRepository>(
      () => BookRepositoryImpl(sl<BookDao>()));
  sl.registerLazySingleton<TranslationRepository>(
      () => TranslationRepositoryImpl(sl<TranslationDao>()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<SettingsLocalDatasource>()));
}

void _initUseCases() {
  sl.registerLazySingleton<ImportBookUseCase>(
      () => ImportBookUseCase(sl<BookRepository>()));
  sl.registerLazySingleton<GetLibraryUseCase>(
      () => GetLibraryUseCase(sl<BookRepository>()));
  sl.registerLazySingleton<TranslateBookUseCase>(
      () => TranslateBookUseCase(sl<TranslationRepository>()));
  sl.registerLazySingleton<PauseTranslationUseCase>(
      () => PauseTranslationUseCase(sl<TranslationRepository>()));
  sl.registerLazySingleton<ResumeTranslationUseCase>(
      () => ResumeTranslationUseCase(sl<TranslationRepository>()));
  sl.registerLazySingleton<CancelTranslationUseCase>(
      () => CancelTranslationUseCase(sl<TranslationRepository>()));
  sl.registerLazySingleton<ExportBookUseCase>(
      () => ExportBookUseCase(sl<BookRepository>()));
  sl.registerLazySingleton<GetHistoryUseCase>(
      () => GetHistoryUseCase(sl<SettingsRepository>()));
}

void _initServices() {
  final importers = [
    EpubImportService(),
    PdfImportService(),
    DocxImportService(),
    TxtImportService(),
  ];
  sl.registerLazySingleton<FileImportServiceFactory>(
      () => FileImportServiceFactory(importers));

  final exporters = [
    EpubExportService(),
    PdfExportService(),
    DocxExportService(),
    TxtExportService(),
  ];
  sl.registerLazySingleton<FileExportServiceFactory>(
      () => FileExportServiceFactory(exporters));

  sl.registerLazySingleton<TextSegmenter>(() => TextSegmenter());
  sl.registerLazySingleton<FormatPreserver>(() => FormatPreserver());

  final cache = TranslationCache(
    datasource: sl<TranslationCacheDatasource>(),
  );
  sl.registerLazySingleton<TranslationCache>(() => cache);

  final engine = MLKitTranslationEngine(cache: sl<TranslationCache>());
  sl.registerLazySingleton<TranslationEngine>(() => engine);

  sl.registerLazySingleton<TranslationService>(
      () => TranslationService(
        sl<TranslationEngine>(),
        cache: sl<TranslationCache>(),
      ));

  sl.registerLazySingleton<TranslationWorker>(
      () => TranslationWorker(
        engine: sl<TranslationEngine>(),
        segmenter: sl<TextSegmenter>(),
      ));

  final notifications = NotificationService();
  sl.registerLazySingleton<NotificationService>(() => notifications);

  sl.registerLazySingleton<BookTranslationOrchestrator>(
      () => BookTranslationOrchestrator(
        bookDao: sl<BookDao>(),
        translationDao: sl<TranslationDao>(),
        importFactory: sl<FileImportServiceFactory>(),
        exportFactory: sl<FileExportServiceFactory>(),
        segmenter: sl<TextSegmenter>(),
        engine: sl<TranslationEngine>(),
        formatPreserver: sl<FormatPreserver>(),
        worker: sl<TranslationWorker>(),
        notificationService: sl<NotificationService>(),
      ));
}
