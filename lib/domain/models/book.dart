import 'package:equatable/equatable.dart';

enum BookFormat { epub, pdf, docx, txt }

enum TranslationStatus { pending, inProgress, paused, completed, cancelled, error }

class Book extends Equatable {
  final String id;
  final String title;
  final String? author;
  final BookFormat format;
  final String filePath;
  final String? coverImagePath;
  final int fileSize;
  final int totalChunks;
  final int translatedChunks;
  final int totalWords;
  final int translatedWords;
  final TranslationStatus translationStatus;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? outputPath;

  const Book({
    required this.id,
    required this.title,
    this.author,
    required this.format,
    required this.filePath,
    this.coverImagePath,
    required this.fileSize,
    this.totalChunks = 0,
    this.translatedChunks = 0,
    this.totalWords = 0,
    this.translatedWords = 0,
    this.translationStatus = TranslationStatus.pending,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'es',
    required this.createdAt,
    this.updatedAt,
    this.outputPath,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    BookFormat? format,
    String? filePath,
    String? coverImagePath,
    int? fileSize,
    int? totalChunks,
    int? translatedChunks,
    int? totalWords,
    int? translatedWords,
    TranslationStatus? translationStatus,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? outputPath,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      filePath: filePath ?? this.filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      fileSize: fileSize ?? this.fileSize,
      totalChunks: totalChunks ?? this.totalChunks,
      translatedChunks: translatedChunks ?? this.translatedChunks,
      totalWords: totalWords ?? this.totalWords,
      translatedWords: translatedWords ?? this.translatedWords,
      translationStatus: translationStatus ?? this.translationStatus,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      outputPath: outputPath ?? this.outputPath,
    );
  }

  double get progressPercent {
    if (totalChunks == 0) return 0;
    return translatedChunks / totalChunks;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        format,
        filePath,
        coverImagePath,
        fileSize,
        totalChunks,
        translatedChunks,
        totalWords,
        translatedWords,
        translationStatus,
        sourceLanguage,
        targetLanguage,
        createdAt,
        updatedAt,
        outputPath,
      ];
}
