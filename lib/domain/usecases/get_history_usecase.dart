import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/translation_stats.dart';
import '../repositories/settings_repository.dart';

class GetHistoryUseCase {
  final SettingsRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<Either<Failure, TranslationStats>> call() async {
    try {
      final stats = await _repository.getStats();
      return Right(stats);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure(
        message: 'Error loading history: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
