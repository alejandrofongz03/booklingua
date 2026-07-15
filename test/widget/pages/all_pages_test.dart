import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/ui/features/home/presentation/pages/home_page.dart';
import 'package:booklingua/ui/features/home/providers/home_provider.dart';
import 'package:booklingua/ui/features/library/presentation/pages/library_page.dart';
import 'package:booklingua/ui/features/library/providers/library_provider.dart';
import 'package:booklingua/ui/features/translate/presentation/pages/translate_page.dart';
import 'package:booklingua/ui/features/translate/providers/translate_provider.dart';
import 'package:booklingua/ui/features/history/presentation/pages/history_page.dart';
import 'package:booklingua/ui/features/history/providers/history_provider.dart';
import 'package:booklingua/ui/features/settings/presentation/pages/settings_page.dart';
import 'package:booklingua/ui/features/settings/providers/settings_provider.dart';
import 'package:booklingua/domain/models/book.dart';
import 'package:booklingua/domain/models/translation_stats.dart';

// Mock notifiers
class MockHomeNotifier extends StateNotifier<HomeState> {
  MockHomeNotifier() : super(HomeState(greeting: 'Buenos días'));

  @override
  void refresh() {}
}

class MockLibraryNotifier extends StateNotifier<LibraryState> {
  MockLibraryNotifier()
      : super(LibraryState(
          books: [],
          isLoading: false,
          error: null,
        ));
  @override
  void refresh() {}
  @override
  void search(String query) {}
}

class MockTranslateNotifier extends StateNotifier<TranslateState> {
  MockTranslateNotifier() : super(const TranslateState());
  @override
  void selectFile({required String filePath, required String fileName, required String fileFormat, required int fileSize}) {}
  @override
  void startTranslation() async {}
  @override
  void pauseTranslation() {}
  @override
  void resumeTranslation() {}
  @override
  void cancelTranslation() {}
  @override
  void clearFile() {}
}

class MockHistoryNotifier extends StateNotifier<HistoryState> {
  MockHistoryNotifier()
      : super(HistoryState(
          items: [],
          stats: TranslationStats(
            totalBooks: 0,
            completedBooks: 0,
            inProgressBooks: 0,
            totalWordsTranslated: 0,
            totalTimeSpent: Duration.zero,
            averageSpeedWordsPerMinute: 0,
          ),
          isLoading: false,
          error: null,
        ));
  @override
  void refresh() {}
}

class MockSettingsNotifier extends StateNotifier<SettingsState> {
  MockSettingsNotifier()
      : super(SettingsState(
          locale: 'es',
          isDarkMode: false,
          autoTranslate: true,
          maxConcurrent: 1,
        ));
  @override
  void setLocale(String locale) {}
  @override
  void toggleDarkMode() {}
  @override
  void setAutoTranslate(bool value) {}
  @override
  void setMaxConcurrent(int value) {}
}

// Provider overrides
final homeProviderOverride = StateNotifierProvider<MockHomeNotifier, HomeState>((ref) => MockHomeNotifier());
final libraryProviderOverride = StateNotifierProvider<MockLibraryNotifier, LibraryState>((ref) => MockLibraryNotifier());
final translateProviderOverride = StateNotifierProvider<MockTranslateNotifier, TranslateState>((ref) => MockTranslateNotifier());
final historyProviderOverride1 = StateNotifierProvider<MockHistoryNotifier, HistoryState>((ref) => MockHistoryNotifier());
final settingsProviderOverride = StateNotifierProvider<MockSettingsNotifier, SettingsState>((ref) => MockSettingsNotifier());

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      homeProvider.overrideWithProvider(homeProviderOverride),
      libraryProvider.overrideWithProvider(libraryProviderOverride),
      translateProvider.overrideWithProvider(translateProviderOverride),
      historyProvider.overrideWithProvider(historyProviderOverride1),
      settingsProvider.overrideWithProvider(settingsProviderOverride),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('HomePage', () {
    testWidgets('renders greeting and quick actions', (tester) async {
      await tester.pumpWidget(createTestApp(const HomePage()));
      await tester.pumpAndSettle();

      expect(find.text('Buenos días'), findsOneWidget);
      expect(find.text('Importar libro'), findsOneWidget);
      expect(find.text('Biblioteca'), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Resumen'), findsOneWidget);
    });

    testWidgets('shows stats section', (tester) async {
      await tester.pumpWidget(createTestApp(const HomePage()));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
      expect(find.text('Libros'), findsWidgets);
    });
  });

  group('LibraryPage', () {
    testWidgets('shows empty state when no books', (tester) async {
      await tester.pumpWidget(createTestApp(const LibraryPage()));
      await tester.pumpAndSettle();

      expect(find.text('Tu biblioteca está vacía'), findsOneWidget);
      expect(find.text('Importar libro'), findsOneWidget);
    });

    testWidgets('shows books when available', (tester) async {
      final bookProvider = StateNotifierProvider<MockLibraryNotifier, LibraryState>((ref) {
        return MockLibraryNotifier()..state = LibraryState(
          books: [
            Book(
              id: '1',
              title: 'Test Book',
              author: 'Author',
              filePath: '/tmp/test.epub',
              format: BookFormat.epub,
              fileSize: 1024,
              sourceLanguage: 'en',
              targetLanguage: 'es',
              totalWords: 1000,
              totalChunks: 10,
              translationStatus: TranslationStatus.completed,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          isLoading: false,
          error: null,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            libraryProvider.overrideWithProvider(bookProvider),
          ],
          child: const MaterialApp(home: LibraryPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Author'), findsOneWidget);
      expect(find.text('Completado'), findsOneWidget);
    });
  });

  group('TranslatePage', () {
    testWidgets('shows import view by default', (tester) async {
      await tester.pumpWidget(createTestApp(const TranslatePage()));
      await tester.pumpAndSettle();

      expect(find.text('Selecciona un libro'), findsOneWidget);
      expect(find.text('Seleccionar archivo'), findsOneWidget);
    });

    testWidgets('shows completed view after translation', (tester) async {
      final completedProvider = StateNotifierProvider<MockTranslateNotifier, TranslateState>((ref) {
        return MockTranslateNotifier()..state = const TranslateState(
          step: TranslateStep.completed,
          filePath: '/tmp/test.epub',
          fileName: 'test.epub',
          fileFormat: 'epub',
          fileSize: 1024,
          exportPath: '/tmp/test_traduccion.epub',
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            translateProvider.overrideWithProvider(completedProvider),
          ],
          child: const MaterialApp(home: TranslatePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¡Traducción completada!'), findsOneWidget);
      expect(find.text('Exportar como...'), findsOneWidget);
      expect(find.text('Archivo guardado'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      final errorProvider = StateNotifierProvider<MockTranslateNotifier, TranslateState>((ref) {
        return MockTranslateNotifier()..state = const TranslateState(
          step: TranslateStep.error,
          error: 'Error de prueba',
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            translateProvider.overrideWithProvider(errorProvider),
          ],
          child: const MaterialApp(home: TranslatePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error de prueba'), findsOneWidget);
    });
  });

  group('HistoryPage', () {
    testWidgets('shows empty state when no history', (tester) async {
      await tester.pumpWidget(createTestApp(const HistoryPage()));
      await tester.pumpAndSettle();

      expect(find.text('Sin historial'), findsOneWidget);
    });

    testWidgets('shows stats and history items', (tester) async {
      final historyProvider = StateNotifierProvider<MockHistoryNotifier, HistoryState>((ref) {
        return MockHistoryNotifier()..state = HistoryState(
          items: [
            HistoryItem(
              id: '1',
              title: 'Test Book',
              format: 'EPUB',
              date: '12/07/2026',
              wordsTranslated: 1000,
            ),
          ],
          stats: TranslationStats(
            totalBooks: 1,
            completedBooks: 1,
            inProgressBooks: 0,
            totalWordsTranslated: 1000,
            totalTimeSpent: Duration(minutes: 10),
            averageSpeedWordsPerMinute: 100,
          ),
          isLoading: false,
          error: null,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyProvider.overrideWithProvider(historyProvider),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('Test Book'), findsOneWidget);
    });
  });

  group('SettingsPage', () {
    testWidgets('renders settings options', (tester) async {
      await tester.pumpWidget(createTestApp(const SettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Idiomas'), findsOneWidget);
      expect(find.text('Traducción'), findsOneWidget);
      expect(find.text('Apariencia'), findsOneWidget);
      expect(find.text('Modo oscuro'), findsOneWidget);
      expect(find.text('Información'), findsOneWidget);
    });
  });
}
