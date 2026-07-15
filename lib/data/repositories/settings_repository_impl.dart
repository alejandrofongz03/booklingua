import '../../domain/models/translation_stats.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  static const _keySourceLanguage = 'source_language';
  static const _keyTargetLanguage = 'target_language';
  static const _keyTranslationEngine = 'translation_engine';
  static const _keyTranslationQuality = 'translation_quality';
  static const _keyDarkMode = 'dark_mode';
  static const _keyMaxChunkSize = 'max_chunk_size';
  static const _keyStats = 'translation_stats';

  @override
  Future<String> getSourceLanguage() async {
    return _datasource.get(_keySourceLanguage) ?? 'en';
  }

  @override
  Future<void> setSourceLanguage(String language) async {
    await _datasource.set(_keySourceLanguage, language);
  }

  @override
  Future<String> getTargetLanguage() async {
    return _datasource.get(_keyTargetLanguage) ?? 'es';
  }

  @override
  Future<void> setTargetLanguage(String language) async {
    await _datasource.set(_keyTargetLanguage, language);
  }

  @override
  Future<String> getTranslationEngine() async {
    return _datasource.get(_keyTranslationEngine) ?? 'mlkit';
  }

  @override
  Future<void> setTranslationEngine(String engine) async {
    await _datasource.set(_keyTranslationEngine, engine);
  }

  @override
  Future<String> getTranslationQuality() async {
    return _datasource.get(_keyTranslationQuality) ?? 'high';
  }

  @override
  Future<void> setTranslationQuality(String quality) async {
    await _datasource.set(_keyTranslationQuality, quality);
  }

  @override
  Future<bool> getDarkMode() async {
    return _datasource.get(_keyDarkMode) == 'true';
  }

  @override
  Future<void> setDarkMode(bool darkMode) async {
    await _datasource.set(_keyDarkMode, darkMode.toString());
  }

  @override
  Future<int> getMaxChunkSize() async {
    final value = _datasource.get(_keyMaxChunkSize);
    return value != null ? int.parse(value) : 5000;
  }

  @override
  Future<void> setMaxChunkSize(int size) async {
    await _datasource.set(_keyMaxChunkSize, size.toString());
  }

  @override
  Future<TranslationStats> getStats() async {
    final data = _datasource.get(_keyStats);
    if (data == null) return const TranslationStats();
    try {
      final parts = data.split(',');
      return TranslationStats(
        totalBooks: int.parse(parts[0]),
        completedBooks: int.parse(parts[1]),
        inProgressBooks: int.parse(parts[2]),
        totalWordsTranslated: int.parse(parts[3]),
        totalChunksTranslated: int.parse(parts[4]),
        averageSpeedWordsPerMinute: double.parse(parts[5]),
        totalTimeSpent: Duration(seconds: int.parse(parts[6])),
      );
    } catch (_) {
      return const TranslationStats();
    }
  }

  @override
  Future<void> updateStats(TranslationStats stats) async {
    final data =
        '${stats.totalBooks},${stats.completedBooks},${stats.inProgressBooks},'
        '${stats.totalWordsTranslated},${stats.totalChunksTranslated},'
        '${stats.averageSpeedWordsPerMinute},${stats.totalTimeSpent.inSeconds}';
    await _datasource.set(_keyStats, data);
  }
}
