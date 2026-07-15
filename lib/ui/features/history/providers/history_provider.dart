import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/models/translation_stats.dart';
import '../../../../domain/repositories/book_repository.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../shared/providers/shared_providers.dart';

class HistoryState {
  final bool isLoading;
  final TranslationStats stats;
  final List<HistoryItem> items;
  final String? error;

  const HistoryState({
    this.isLoading = true,
    this.stats = const TranslationStats(),
    this.items = const [],
    this.error,
  });

  HistoryState copyWith({
    bool? isLoading,
    TranslationStats? stats,
    List<HistoryItem>? items,
    String? error,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

class HistoryItem {
  final String id;
  final String title;
  final String date;
  final String format;
  final int wordsTranslated;

  const HistoryItem({
    required this.id,
    required this.title,
    required this.date,
    required this.format,
    required this.wordsTranslated,
  });
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final SettingsRepository _settingsRepository;
  final BookRepository _bookRepository;

  HistoryNotifier(this._settingsRepository, this._bookRepository)
      : super(const HistoryState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final completedBooks =
          await _bookRepository.getByStatus(TranslationStatus.completed);

      final items = completedBooks.map((book) {
        final date = book.updatedAt ?? book.createdAt;
        return HistoryItem(
          id: book.id,
          title: book.title,
          date:
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          format: book.format.name.toUpperCase(),
          wordsTranslated: book.translatedWords,
        );
      }).toList();

      final totalWords =
          completedBooks.fold<int>(0, (sum, b) => sum + b.translatedWords);

      final savedStats = await _settingsRepository.getStats();
      final stats = savedStats.copyWith(
        totalBooks: completedBooks.length,
        completedBooks: completedBooks.length,
        totalWordsTranslated: totalWords,
      );

      state = state.copyWith(isLoading: false, stats: stats, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final settingsRepo = ref.read(settingsRepositoryProvider);
  final bookRepo = ref.read(bookRepositoryProvider);
  return HistoryNotifier(settingsRepo, bookRepo);
});
