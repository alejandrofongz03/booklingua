import '../models/translation_stats.dart';

class SettingsRepository {
  Future<String> getSourceLanguage();
  Future<void> setSourceLanguage(String language);
  Future<String> getTargetLanguage();
  Future<void> setTargetLanguage(String language);
  Future<String> getTranslationEngine();
  Future<void> setTranslationEngine(String engine);
  Future<String> getTranslationQuality();
  Future<void> setTranslationQuality(String quality);
  Future<bool> getDarkMode();
  Future<void> setDarkMode(bool darkMode);
  Future<int> getMaxChunkSize();
  Future<void> setMaxChunkSize(int size);
  Future<TranslationStats> getStats();
  Future<void> updateStats(TranslationStats stats);
}
