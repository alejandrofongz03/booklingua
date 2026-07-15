import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookLingua'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(homeProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreeting(context, state.greeting),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildStats(context, ref),
          ].animate(interval: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String greeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Traduce tus libros completos de Inglés a Español',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones rápidas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.add_circle_outline,
                label: 'Importar libro',
                color: AppColors.primary,
                onTap: () => context.go('/translate'),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.library_books_outlined,
                label: 'Biblioteca',
                color: AppColors.tertiary,
                onTap: () => context.go('/library'),
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideY(begin: 0.1, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.history,
                label: 'Historial',
                color: AppColors.secondary,
                onTap: () => context.go('/history'),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                color: AppColors.info,
                onTap: () => context.go('/settings'),
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.1, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final stats = state.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.menu_book,
                  label: 'Libros',
                  value: '${stats?.totalBooks ?? 0}',
                  context: context,
                ),
                const VerticalDivider(),
                _StatItem(
                  icon: Icons.check_circle,
                  label: 'Completados',
                  value: '${stats?.completedBooks ?? 0}',
                  context: context,
                ),
                const VerticalDivider(),
                _StatItem(
                  icon: Icons.abc,
                  label: 'Palabras',
                  value: _formatNumber(stats?.totalWordsTranslated ?? 0),
                  context: context,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.08, end: 0),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
      ),
    );
  }
}
