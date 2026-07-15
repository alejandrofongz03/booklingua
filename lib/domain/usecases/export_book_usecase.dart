import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

class ExportBookUseCase {
  final BookRepository _repository;

  ExportBookUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required String bookId,
    required String targetFormat,
  }) async {
    try {
      final book = await _repository.getById(bookId);
      if (book == null) {
        return Left(FileExportFailure(message: 'Book not found'));
      }
      final outputPath = book.outputPath;
      if (outputPath == null) {
        return Left(FileExportFailure(message: 'No output path available'));
      }
      return Right(outputPath);
    } catch (e, stackTrace) {
      return Left(FileExportFailure(
        message: 'Error exporting book: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
