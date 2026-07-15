import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../domain/models/translation_stats.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          if (!state.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(historyProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HistoryState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando historial...')
          .animate().fadeIn(duration: 300.ms);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(historyProvider.notifier).refresh(),
      ).animate().fadeIn(duration: 300.ms);
    }

    if (state.stats.totalBooks == 0) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: 'Sin historial',
        subtitle: 'Las traducciones completadas aparecerán aquí',
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsSection(context, state.stats)
            .animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 16),
        ...state.items.asMap().entries.map(
          (entry) => _HistoryTile(item: entry.value)
              .animate()
              .fadeIn(duration: 300.ms, delay: (entry.key * 50 + 200).ms)
              .slideY(begin: 0.05, end: 0),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, TranslationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Libros',
                    value: '${stats.totalBooks}',
                    icon: Icons.menu_book,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Completados',
                    value: '${stats.completedBooks}',
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Palabras',
                    value: _formatNumber(stats.totalWordsTranslated),
                    icon: Icons.abc,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Tiempo total',
                    value: _formatDuration(stats.totalTimeSpent),
                    icon: Icons.timer,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Velocidad',
                    value: '${stats.averageSpeedWordsPerMinute.toStringAsFixed(0)}',
                    icon: Icons.speed,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'En progreso',
                    value: '${stats.inProgressBooks}',
                    icon: Icons.sync,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(item.title),
        subtitle: Text('${item.date} - ${item.format} - ${_formatNumber(item.wordsTranslated)} palabras'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}
