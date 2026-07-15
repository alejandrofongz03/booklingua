import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/translation_repository.dart';

class ResumeTranslationUseCase {
  final TranslationRepository _repository;

  ResumeTranslationUseCase(this._repository);

  Future<Either<Failure, void>> call(String bookId) async {
    try {
      await _repository.resumeTranslation(bookId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(TranslationFailure(
        message: 'Error resuming translation: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
