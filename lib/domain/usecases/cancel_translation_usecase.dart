import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/translation_repository.dart';

class CancelTranslationUseCase {
  final TranslationRepository _repository;

  CancelTranslationUseCase(this._repository);

  Future<Either<Failure, void>> call(String bookId) async {
    try {
      await _repository.cancelTranslation(bookId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(TranslationFailure(
        message: 'Error cancelling translation: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
