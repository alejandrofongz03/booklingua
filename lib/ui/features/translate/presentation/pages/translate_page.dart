import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../services/background/book_translation_orchestrator.dart';
import '../../../shared/widgets/progress_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../providers/translate_provider.dart';

class TranslatePage extends ConsumerStatefulWidget {
  const TranslatePage({super.key});

  @override
  ConsumerState<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends ConsumerState<TranslatePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traducir libro'),
      ),
      body: switch (state.step) {
        TranslateStep.selectFile => _buildImportView().animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        TranslateStep.configuring => _buildConfigView(state).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        TranslateStep.translating => _buildTranslationView(state).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
        TranslateStep.completed => _buildCompletedView(state).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0),
        TranslateStep.error => AppErrorWidget(
            message: state.error ?? 'Error desconocido',
            onRetry: () => ref.read(translateProvider.notifier).clearFile(),
          ).animate().fadeIn(duration: 300.ms),
      },
    );
  }

  Widget _buildImportView() {
    return EmptyStateWidget(
      icon: Icons.upload_file,
      title: 'Selecciona un libro',
      subtitle:
          'Formatos soportados: EPUB, PDF, DOCX, TXT\nLos libros se traducen completamente sin conexión',
      actionLabel: 'Seleccionar archivo',
      onAction: _pickFile,
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildConfigView(TranslateState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getFormatIcon(state.fileFormat ?? ''),
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.fileName ?? 'Archivo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.fileFormat?.toUpperCase()} - ${FileUtils.formatFileSize(state.fileSize ?? 0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(translateProvider.notifier).clearFile(),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 24),
        _buildLanguageSelector(context).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              ref.read(translateProvider.notifier).startTranslation(),
          icon: const Icon(Icons.translate),
          label: const Text('Comenzar traducción'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Idiomas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LanguageChip(
                    label: 'Inglés',
                    icon: Icons.flag,
                    isSelected: true,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: _LanguageChip(
                    label: 'Español',
                    icon: Icons.flag,
                    isSelected: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationView(TranslateState state) {
    final progress = state.progress;
    final percent = progress?.progress ?? 0;
    final words = progress?.translatedWords ?? 0;
    final totalWords = progress?.totalWords ?? 0;
    final elapsed = progress?.elapsedSeconds ?? 0;
    final remaining = _formatRemaining(
      progress?.completedChunks ?? 0,
      progress?.totalChunks ?? 0,
      elapsed,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TranslationProgressWidget(
          progress: percent.clamp(0.0, 1.0),
          title: state.fileName ?? 'Traduciendo...',
          subtitle: state.fileFormat?.toUpperCase(),
          timeRemaining: remaining,
          wordsTranslated: '$words de $totalWords palabras traducidas',
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: state.isPaused
                  ? FilledButton.icon(
                      onPressed: () =>
                          ref.read(translateProvider.notifier).resumeTranslation(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Reanudar'),
                    ).animate().fadeIn(duration: 200.ms)
                  : OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(translateProvider.notifier).pauseTranslation(),
                      icon: const Icon(Icons.pause),
                      label: const Text('Pausar'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(translateProvider.notifier).cancelTranslation(),
                icon: const Icon(Icons.stop),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ).animate().fadeIn(duration: 200.ms, delay: 200.ms),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletedView(TranslateState state) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.check_circle,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ).animate().scale(duration: 500.ms, begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          '¡Traducción completada!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Text(
          '${state.fileName} ha sido traducido exitosamente.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (state.exportPath != null) ...[
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.file_present, color: Colors.green),
              title: const Text('Archivo guardado'),
              subtitle: Text(
                state.exportPath!.split('\\').last.split('/').last,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  final path = state.exportPath;
                  if (path == null) return;
                  if (value == 'open') {
                    await OpenFilex.open(path);
                  } else if (value == 'share') {
                    await Share.shareXFiles([XFile(path)]);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: ListTile(
                      leading: Icon(Icons.open_in_new),
                      title: Text('Abrir'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Compartir'),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.08, end: 0),
        ],
        const SizedBox(height: 32),
        Text(
          'Exportar como...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        ..._buildExportButtons(state),
        if (state.isExporting) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Exportando...', textAlign: TextAlign.center),
        ],
        if (state.exportError != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.exportError!)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(translateProvider.notifier).clearFile(),
          icon: const Icon(Icons.add),
          label: const Text('Traducir otro libro'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  List<Widget> _buildExportButtons(TranslateState state) {
    final formats = [
      ('epub', Icons.menu_book, 'EPUB'),
      ('pdf', Icons.picture_as_pdf, 'PDF'),
      ('docx', Icons.description, 'DOCX'),
      ('txt', Icons.article, 'TXT'),
    ];

    return [
      Row(
        children: [
          Expanded(
            child: _ExportButton(
              icon: formats[0].$2,
              label: formats[0].$3,
              onTap: () => ref
                  .read(translateProvider.notifier)
                  .exportBook(formats[0].$1),
              isSelected: state.exportPath?.endsWith('.${formats[0].$1}') ?? false,
            ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideY(begin: 0.15, end: 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ExportButton(
              icon: formats[1].$2,
              label: formats[1].$3,
              onTap: () => ref
                  .read(translateProvider.notifier)
                  .exportBook(formats[1].$1),
              isSelected: state.exportPath?.endsWith('.${formats[1].$1}') ?? false,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.15, end: 0),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _ExportButton(
              icon: formats[2].$2,
              label: formats[2].$3,
              onTap: () => ref
                  .read(translateProvider.notifier)
                  .exportBook(formats[2].$1),
              isSelected: state.exportPath?.endsWith('.${formats[2].$1}') ?? false,
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideY(begin: 0.15, end: 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ExportButton(
              icon: formats[3].$2,
              label: formats[3].$3,
              onTap: () => ref
                  .read(translateProvider.notifier)
                  .exportBook(formats[3].$1),
              isSelected: state.exportPath?.endsWith('.${formats[3].$1}') ?? false,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.15, end: 0),
          ),
        ],
      ),
    ];
  }

  String? _formatRemaining(int completed, int total, int elapsed) {
    if (completed == 0 || total == 0) return null;
    final perChunk = elapsed / completed;
    final remaining = (perChunk * (total - completed)).round();
    if (remaining >= 3600) {
      return '${remaining ~/ 3600}h ${(remaining % 3600) ~/ 60}m restantes';
    } else if (remaining >= 60) {
      return '${remaining ~/ 60}m ${remaining % 60}s restantes';
    }
    return '${remaining}s restantes';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedFormats,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final notifier = ref.read(translateProvider.notifier);
      await notifier.selectFile(
        filePath: path,
        fileName: result.files.single.name,
        fileFormat: FileUtils.detectFormat(path),
        fileSize: result.files.single.size,
      );
    }
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'epub':
        return Icons.menu_book;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? scheme.primaryContainer : scheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const _LanguageChip({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
