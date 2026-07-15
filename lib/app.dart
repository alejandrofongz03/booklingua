import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/router/app_router.dart';
import 'ui/features/settings/providers/settings_provider.dart';

class BookLinguaApp extends ConsumerWidget {
  const BookLinguaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(
      settingsProvider.select((s) => s.darkMode),
    );

    return MaterialApp.router(
      title: 'BookLingua',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
