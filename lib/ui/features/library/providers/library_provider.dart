import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/repositories/book_repository.dart';
import '../../../shared/providers/shared_providers.dart';

class LibraryState {
  final bool isLoading;
  final List<Book> books;
  final String? error;

  const LibraryState({
    this.isLoading = true,
    this.books = const [],
    this.error,
  });

  LibraryState copyWith({
    bool? isLoading,
    List<Book>? books,
    String? error,
  }) {
    return LibraryState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      error: error ?? this.error,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final BookRepository _repository;

  LibraryNotifier(this._repository) : super(const LibraryState()) {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _repository.getAll();
      state = state.copyWith(isLoading: false, books: books);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadBooks();
  }

  Future<void> deleteBook(String id) async {
    try {
      await _repository.delete(id);
      await _loadBooks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
  final repository = ref.read(bookRepositoryProvider);
  return LibraryNotifier(repository);
});

final librarySearchProvider = Provider.family<List<Book>, String>((ref, query) {
  final books = ref.watch(libraryProvider).books;
  if (query.isEmpty) return books;
  return books
      .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
      .toList();
});
