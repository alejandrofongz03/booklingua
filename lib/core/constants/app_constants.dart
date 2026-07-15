class AppConstants {
  AppConstants._();

  static const String appName = 'BookLingua';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Traduce libros completos de Inglés a Español';

  static const String defaultSourceLanguage = 'en';
  static const String defaultTargetLanguage = 'es';

  static const int maxChunkSize = 5000;
  static const int maxConcurrentTranslations = 3;
  static const int cacheMaxEntries = 1000;

  static const String dbName = 'booklingua.db';
  static const String cacheBoxName = 'translation_cache';
  static const String settingsBoxName = 'app_settings';

  static const List<String> supportedFormats = ['epub', 'pdf', 'docx', 'txt'];
  static const List<String> exportFormats = ['epub', 'pdf', 'docx', 'txt'];

  static const double minBookSizeBytes = 100;
  static const double maxBookSizeBytes = 500 * 1024 * 1024;

  static const Duration progressUpdateInterval = Duration(milliseconds: 500);
  static const Duration autoSaveInterval = Duration(seconds: 30);
}
