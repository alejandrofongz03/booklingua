import 'package:equatable/equatable.dart';

class BookChunkModel extends Equatable {
  final String id;
  final String bookId;
  final int index;
  final String sourceText;
  final String? translatedText;
  final bool isTranslated;
  final Map<String, dynamic>? formatMetadata;

  const BookChunkModel({
    required this.id,
    required this.bookId,
    required this.index,
    required this.sourceText,
    this.translatedText,
    this.isTranslated = false,
    this.formatMetadata,
  });

  BookChunkModel copyWith({
    String? id,
    String? bookId,
    int? index,
    String? sourceText,
    String? translatedText,
    bool? isTranslated,
    Map<String, dynamic>? formatMetadata,
  }) {
    return BookChunkModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      index: index ?? this.index,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      isTranslated: isTranslated ?? this.isTranslated,
      formatMetadata: formatMetadata ?? this.formatMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'index': index,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'isTranslated': isTranslated,
      'formatMetadata': formatMetadata,
    };
  }

  factory BookChunkModel.fromJson(Map<String, dynamic> json) {
    return BookChunkModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      index: json['index'] as int,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String?,
      isTranslated: json['isTranslated'] as bool? ?? false,
      formatMetadata: json['formatMetadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        index,
        sourceText,
        translatedText,
        isTranslated,
        formatMetadata,
      ];
}
