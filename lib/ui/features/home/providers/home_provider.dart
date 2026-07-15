import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/translation_stats.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../shared/providers/shared_providers.dart';

class HomeState {
  final bool isLoading;
  final String greeting;
  final TranslationStats? stats;
  final String? error;

  const HomeState({
    this.isLoading = true,
    this.greeting = '',
    this.stats,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    String? greeting,
    TranslationStats? stats,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      greeting: greeting ?? this.greeting,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final SettingsRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState()) {
    _load();
  }

  Future<void> _load() async {
    _loadGreeting();
    await _loadStats();
  }

  void _loadGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '¡Buenos días!';
    } else if (hour < 18) {
      greeting = '¡Buenas tardes!';
    } else {
      greeting = '¡Buenas noches!';
    }
    state = state.copyWith(greeting: greeting);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _load();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return HomeNotifier(repository);
});
