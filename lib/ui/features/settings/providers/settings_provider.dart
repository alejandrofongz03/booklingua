import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../shared/providers/shared_providers.dart';

class SettingsState {
  final bool isLoading;
  final String sourceLanguage;
  final String targetLanguage;
  final String translationEngine;
  final String translationQuality;
  final bool darkMode;
  final int maxChunkSize;
  final String? error;

  const SettingsState({
    this.isLoading = true,
    this.sourceLanguage = 'Inglés',
    this.targetLanguage = 'Español',
    this.translationEngine = 'ML Kit',
    this.translationQuality = 'Alta',
    this.darkMode = false,
    this.maxChunkSize = 5000,
    this.error,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? sourceLanguage,
    String? targetLanguage,
    String? translationEngine,
    String? translationQuality,
    bool? darkMode,
    int? maxChunkSize,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translationEngine: translationEngine ?? this.translationEngine,
      translationQuality: translationQuality ?? this.translationQuality,
      darkMode: darkMode ?? this.darkMode,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
      error: error ?? this.error,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final source = await _repository.getSourceLanguage();
      final target = await _repository.getTargetLanguage();
      final engine = await _repository.getTranslationEngine();
      final quality = await _repository.getTranslationQuality();
      final darkMode = await _repository.getDarkMode();
      final maxChunkSize = await _repository.getMaxChunkSize();

      state = SettingsState(
        isLoading: false,
        sourceLanguage: _languageCodeToName(source),
        targetLanguage: _languageCodeToName(target),
        translationEngine: _engineCodeToName(engine),
        translationQuality: _qualityCodeToName(quality),
        darkMode: darkMode,
        maxChunkSize: maxChunkSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setSourceLanguage(String language) async {
    state = state.copyWith(sourceLanguage: language);
    await _repository.setSourceLanguage(_languageNameToCode(language));
  }

  Future<void> setTargetLanguage(String language) async {
    state = state.copyWith(targetLanguage: language);
    await _repository.setTargetLanguage(_languageNameToCode(language));
  }

  Future<void> setTranslationEngine(String engine) async {
    state = state.copyWith(translationEngine: engine);
    await _repository.setTranslationEngine(_engineNameToCode(engine));
  }

  Future<void> setTranslationQuality(String quality) async {
    state = state.copyWith(translationQuality: quality);
    await _repository.setTranslationQuality(_qualityNameToCode(quality));
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _repository.setDarkMode(value);
  }

  Future<void> setMaxChunkSize(int size) async {
    state = state.copyWith(maxChunkSize: size);
    await _repository.setMaxChunkSize(size);
  }

  String _languageCodeToName(String code) {
    switch (code) {
      case 'en': return 'Inglés';
      case 'es': return 'Español';
      case 'fr': return 'Francés';
      case 'de': return 'Alemán';
      case 'it': return 'Italiano';
      case 'pt': return 'Portugués';
      default: return 'Inglés';
    }
  }

  String _languageNameToCode(String name) {
    switch (name) {
      case 'Inglés': return 'en';
      case 'Español': return 'es';
      case 'Francés': return 'fr';
      case 'Alemán': return 'de';
      case 'Italiano': return 'it';
      case 'Portugués': return 'pt';
      default: return 'en';
    }
  }

  String _engineCodeToName(String code) {
    switch (code) {
      case 'mlkit': return 'ML Kit';
      case 'tflite': return 'TFLite';
      case 'deepl': return 'DeepL';
      default: return 'ML Kit';
    }
  }

  String _engineNameToCode(String name) {
    switch (name) {
      case 'ML Kit': return 'mlkit';
      case 'TFLite': return 'tflite';
      case 'DeepL': return 'deepl';
      default: return 'mlkit';
    }
  }

  String _qualityCodeToName(String code) {
    switch (code) {
      case 'high': return 'Alta';
      case 'medium': return 'Media';
      case 'fast': return 'Rápida';
      default: return 'Alta';
    }
  }

  String _qualityNameToCode(String name) {
    switch (name) {
      case 'Alta': return 'high';
      case 'Media': return 'medium';
      case 'Rápida': return 'fast';
      default: return 'high';
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});
