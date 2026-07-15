import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../domain/models/book.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../providers/library_provider.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, ref),
          ),
          if (state.books.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(libraryProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, LibraryState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando biblioteca...')
          .animate().fadeIn(duration: 300.ms);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(libraryProvider.notifier).refresh(),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (state.books.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.library_books_outlined,
        title: 'Tu biblioteca está vacía',
        subtitle: 'Importa un libro EPUB, PDF, DOCX o TXT para comenzar',
        actionLabel: 'Importar libro',
        onAction: () {},
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.books.length,
        itemBuilder: (context, index) =>
            _BookCard(book: state.books[index])
                .animate()
                .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                .slideX(begin: 0.03, end: 0),
      ),
    );
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showSearch(
      context: context,
      delegate: _LibrarySearchDelegate(ref),
    );
  }
}

class _LibrarySearchDelegate extends SearchDelegate<Book?> {
  final WidgetRef ref;

  _LibrarySearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = ref.read(librarySearchProvider(query));
    return _buildSearchResults(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Busca por título del libro'),
      );
    }
    final results = ref.read(librarySearchProvider(query));
    return _buildSearchResults(context, results);
  }

  Widget _buildSearchResults(BuildContext context, List<Book> books) {
    if (books.isEmpty) {
      return const Center(
        child: Text('No se encontraron libros'),
      );
    }
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(
          _formatIcon(books[index].format),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(books[index].title),
        subtitle: Text(books[index].format.name.toUpperCase()),
        onTap: () => close(context, books[index]),
      ),
    );
  }

  IconData _formatIcon(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return Icons.menu_book;
      case BookFormat.pdf:
        return Icons.picture_as_pdf;
      case BookFormat.docx:
        return Icons.description;
      case BookFormat.txt:
        return Icons.article;
    }
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _formatIcon(book.format),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.author!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusChip(status: book.translationStatus),
                        const Spacer(),
                        Text(
                          FileUtils.formatFileSize(book.fileSize),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _formatIcon(BookFormat format) {
    switch (format) {
      case BookFormat.epub:
        return Icons.menu_book;
      case BookFormat.pdf:
        return Icons.picture_as_pdf;
      case BookFormat.docx:
        return Icons.description;
      case BookFormat.txt:
        return Icons.article;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final TranslationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status) {
      TranslationStatus.pending => (AppColors.warning, 'Pendiente'),
      TranslationStatus.inProgress =>
        (AppColors.translationProgress, 'Traduciendo'),
      TranslationStatus.paused => (AppColors.translationPaused, 'Pausado'),
      TranslationStatus.completed =>
        (AppColors.translationComplete, 'Completado'),
      TranslationStatus.cancelled => (AppColors.outline, 'Cancelado'),
      TranslationStatus.error => (AppColors.translationError, 'Error'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
