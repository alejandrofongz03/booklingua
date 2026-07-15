import 'package:equatable/equatable.dart';

class TranslationCacheModel extends Equatable {
  final String sourceHash;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime cachedAt;

  const TranslationCacheModel({
    required this.sourceHash,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceHash': sourceHash,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory TranslationCacheModel.fromJson(Map<String, dynamic> json) {
    return TranslationCacheModel(
      sourceHash: json['sourceHash'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        sourceHash,
        sourceText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        cachedAt,
      ];
}
