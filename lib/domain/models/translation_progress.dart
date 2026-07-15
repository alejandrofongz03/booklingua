import 'package:equatable/equatable.dart';
import 'book.dart';

class TranslationProgress extends Equatable {
  final String bookId;
  final int totalChunks;
  final int completedChunks;
  final int failedChunks;
  final int totalWords;
  final int translatedWords;
  final TranslationStatus status;
  final DateTime startTime;
  final DateTime? pauseTime;
  final int elapsedSeconds;
  final int estimatedRemainingSeconds;

  const TranslationProgress({
    required this.bookId,
    required this.totalChunks,
    this.completedChunks = 0,
    this.failedChunks = 0,
    required this.totalWords,
    this.translatedWords = 0,
    this.status = TranslationStatus.pending,
    required this.startTime,
    this.pauseTime,
    this.elapsedSeconds = 0,
    this.estimatedRemainingSeconds = 0,
  });

  double get progressPercent {
    if (totalChunks == 0) return 0;
    return completedChunks / totalChunks;
  }

  int get activeChunks => completedChunks + failedChunks;

  String get elapsedFormatted => _formatDuration(elapsedSeconds);
  String get remainingFormatted => _formatDuration(estimatedRemainingSeconds);

  static String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  TranslationProgress copyWith({
    String? bookId,
    int? totalChunks,
    int? completedChunks,
    int? failedChunks,
    int? totalWords,
    int? translatedWords,
    TranslationStatus? status,
    DateTime? startTime,
    DateTime? pauseTime,
    int? elapsedSeconds,
    int? estimatedRemainingSeconds,
  }) {
    return TranslationProgress(
      bookId: bookId ?? this.bookId,
      totalChunks: totalChunks ?? this.totalChunks,
      completedChunks: completedChunks ?? this.completedChunks,
      failedChunks: failedChunks ?? this.failedChunks,
      totalWords: totalWords ?? this.totalWords,
      translatedWords: translatedWords ?? this.translatedWords,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      pauseTime: pauseTime ?? this.pauseTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      estimatedRemainingSeconds:
          estimatedRemainingSeconds ?? this.estimatedRemainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        bookId,
        totalChunks,
        completedChunks,
        failedChunks,
        totalWords,
        translatedWords,
        status,
        startTime,
        pauseTime,
        elapsedSeconds,
        estimatedRemainingSeconds,
      ];
}
