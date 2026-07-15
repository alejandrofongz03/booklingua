import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Idiomas',
            icon: Icons.language,
            children: [
              _SettingsTile(
                label: 'Idioma de origen',
                value: state.sourceLanguage,
                icon: Icons.arrow_outward,
                onTap: () => _showLanguagePicker(context, notifier, true, state),
              ),
              _SettingsTile(
                label: 'Idioma de destino',
                value: state.targetLanguage,
                icon: Icons.arrow_forward,
                onTap: () => _showLanguagePicker(context, notifier, false, state),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Traducción',
            icon: Icons.translate,
            children: [
              _SettingsTile(
                label: 'Motor de traducción',
                value: state.translationEngine,
                icon: Icons.memory,
                onTap: () => _showEnginePicker(context, notifier, state),
              ),
              _SettingsTile(
                label: 'Calidad de traducción',
                value: state.translationQuality,
                icon: Icons.quality,
                onTap: () => _showQualityPicker(context, notifier, state),
              ),
              _SettingsTile(
                label: 'Tamaño máximo de bloque',
                value: '${state.maxChunkSize} caracteres',
                icon: Icons.view_stream,
                onTap: () => _showChunkSizePicker(context, notifier, state),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Apariencia',
            icon: Icons.palette,
            children: [
              SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: const Text('Cambiar el tema de la aplicación'),
                secondary: Icon(
                  state.darkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                value: state.darkMode,
                onChanged: (value) => notifier.setDarkMode(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Información',
            icon: Icons.info,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                title: const Text('Versión'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                title: const Text('Acerca de BookLingua'),
                subtitle: const Text('Traductor de libros offline'),
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    SettingsNotifier notifier,
    bool isSource,
    SettingsState state,
  ) {
    final languages = ['Inglés', 'Español', 'Francés', 'Alemán', 'Italiano', 'Portugués'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: isSource ? 'Idioma de origen' : 'Idioma de destino',
        items: languages,
        selectedItem: isSource ? state.sourceLanguage : state.targetLanguage,
        onSelected: (value) {
          if (isSource) notifier.setSourceLanguage(value);
          else notifier.setTargetLanguage(value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showEnginePicker(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Motor de traducción',
        items: const ['ML Kit (Local)', 'TFLite (Local)', 'DeepL (Online)'],
        selectedItem: state.translationEngine,
        onSelected: (value) {
          notifier.setTranslationEngine(value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showQualityPicker(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _PickerSheet(
        title: 'Calidad de traducción',
        items: const ['Alta', 'Media', 'Rápida'],
        selectedItem: state.translationQuality,
        onSelected: (value) {
          notifier.setTranslationQuality(value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showChunkSizePicker(
    BuildContext context,
    SettingsNotifier notifier,
    SettingsState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tamaño de bloque'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Define el tamaño máximo de cada bloque de texto a traducir'),
              const SizedBox(height: 16),
              Slider(
                value: state.maxChunkSize.toDouble(),
                min: 1000,
                max: 20000,
                divisions: 19,
                label: '${state.maxChunkSize}',
                onChanged: (value) {
                  notifier.setMaxChunkSize(value.toInt());
                  setDialogState(() {});
                },
              ),
              Text('${state.maxChunkSize} caracteres por bloque'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CERRAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BookLingua',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.translate, size: 48, color: AppColors.primary),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Traduce libros completos de Inglés a Español '
          'utilizando inteligencia artificial local.\n\n'
          'Soporta EPUB, PDF, DOCX y TXT.',
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => ListTile(
                title: Text(item),
                leading: Radio<String>(
                  value: item,
                  groupValue: selectedItem,
                  onChanged: (value) {
                    if (value != null) onSelected(value);
                  },
                ),
                onTap: () => onSelected(item),
              )),
        ],
      ),
    );
  }
}
