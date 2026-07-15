import 'package:equatable/equatable.dart';

class TranslationStats extends Equatable {
  final int totalBooks;
  final int completedBooks;
  final int inProgressBooks;
  final int totalWordsTranslated;
  final int totalChunksTranslated;
  final double averageSpeedWordsPerMinute;
  final Duration totalTimeSpent;

  const TranslationStats({
    this.totalBooks = 0,
    this.completedBooks = 0,
    this.inProgressBooks = 0,
    this.totalWordsTranslated = 0,
    this.totalChunksTranslated = 0,
    this.averageSpeedWordsPerMinute = 0,
    this.totalTimeSpent = Duration.zero,
  });

  TranslationStats copyWith({
    int? totalBooks,
    int? completedBooks,
    int? inProgressBooks,
    int? totalWordsTranslated,
    int? totalChunksTranslated,
    double? averageSpeedWordsPerMinute,
    Duration? totalTimeSpent,
  }) {
    return TranslationStats(
      totalBooks: totalBooks ?? this.totalBooks,
      completedBooks: completedBooks ?? this.completedBooks,
      inProgressBooks: inProgressBooks ?? this.inProgressBooks,
      totalWordsTranslated: totalWordsTranslated ?? this.totalWordsTranslated,
      totalChunksTranslated: totalChunksTranslated ?? this.totalChunksTranslated,
      averageSpeedWordsPerMinute:
          averageSpeedWordsPerMinute ?? this.averageSpeedWordsPerMinute,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }

  @override
  List<Object?> get props => [
        totalBooks,
        completedBooks,
        inProgressBooks,
        totalWordsTranslated,
        totalChunksTranslated,
        averageSpeedWordsPerMinute,
        totalTimeSpent,
      ];
}
