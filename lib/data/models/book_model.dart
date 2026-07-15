import 'package:equatable/equatable.dart';
import '../../domain/models/book.dart';

class BookModel extends Equatable {
  final String id;
  final String title;
  final String? author;
  final String format;
  final String filePath;
  final String? coverImagePath;
  final int fileSize;
  final int totalChunks;
  final int translatedChunks;
  final int totalWords;
  final int translatedWords;
  final String translationStatus;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? outputPath;

  const BookModel({
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
    this.translationStatus = 'pending',
    this.sourceLanguage = 'en',
    this.targetLanguage = 'es',
    required this.createdAt,
    this.updatedAt,
    this.outputPath,
  });

  factory BookModel.fromDomain(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      format: book.format.name,
      filePath: book.filePath,
      coverImagePath: book.coverImagePath,
      fileSize: book.fileSize,
      totalChunks: book.totalChunks,
      translatedChunks: book.translatedChunks,
      totalWords: book.totalWords,
      translatedWords: book.translatedWords,
      translationStatus: book.translationStatus.name,
      sourceLanguage: book.sourceLanguage,
      targetLanguage: book.targetLanguage,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      outputPath: book.outputPath,
    );
  }

  Book toDomain() {
    return Book(
      id: id,
      title: title,
      author: author,
      format: BookFormat.values.firstWhere((f) => f.name == format),
      filePath: filePath,
      coverImagePath: coverImagePath,
      fileSize: fileSize,
      totalChunks: totalChunks,
      translatedChunks: translatedChunks,
      totalWords: totalWords,
      translatedWords: translatedWords,
      translationStatus: TranslationStatus.values.firstWhere(
        (s) => s.name == translationStatus,
      ),
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      outputPath: outputPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'format': format,
      'filePath': filePath,
      'coverImagePath': coverImagePath,
      'fileSize': fileSize,
      'totalChunks': totalChunks,
      'translatedChunks': translatedChunks,
      'totalWords': totalWords,
      'translatedWords': translatedWords,
      'translationStatus': translationStatus,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'outputPath': outputPath,
    };
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      format: json['format'] as String,
      filePath: json['filePath'] as String,
      coverImagePath: json['coverImagePath'] as String?,
      fileSize: json['fileSize'] as int,
      totalChunks: json['totalChunks'] as int? ?? 0,
      translatedChunks: json['translatedChunks'] as int? ?? 0,
      totalWords: json['totalWords'] as int? ?? 0,
      translatedWords: json['translatedWords'] as int? ?? 0,
      translationStatus: json['translationStatus'] as String? ?? 'pending',
      sourceLanguage: json['sourceLanguage'] as String? ?? 'en',
      targetLanguage: json['targetLanguage'] as String? ?? 'es',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      outputPath: json['outputPath'] as String?,
    );
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
