import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/book_repository.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../di/injection_container.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return sl<BookRepository>();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return sl<SettingsRepository>();
});
