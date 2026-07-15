import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/translation_progress.dart';
import '../repositories/translation_repository.dart';

class TranslateBookUseCase {
  final TranslationRepository _repository;

  TranslateBookUseCase(this._repository);

  Future<Either<Failure, void>> startTranslation(String bookId) async {
    try {
      await _repository.startTranslation(bookId);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(TranslationFailure(
        message: 'Error starting translation: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  Stream<TranslationProgress> watchProgress(String bookId) {
    return _repository.watchProgress(bookId);
  }
}
