import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/translation_repository.dart';

class PauseTranslationUseCase {
  final TranslationRepository _repository;

  PauseTranslationUseCase(this._repository);

  Future<Either<Failure, void>> call(String bookId) async {
    try {
      await _repository.pauseTranslation(bookId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(TranslationFailure(
        message: 'Error pausing translation: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
