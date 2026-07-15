import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

class GetLibraryUseCase {
  final BookRepository _repository;

  GetLibraryUseCase(this._repository);

  Stream<List<Book>> watchAll() => _repository.watchAll();

  Future<Either<Failure, List<Book>>> getAll() async {
    try {
      final books = await _repository.getAll();
      return Right(books);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure(
        message: 'Error loading library: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Either<Failure, Book?>> getById(String id) async {
    try {
      final book = await _repository.getById(id);
      return Right(book);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure(
        message: 'Error loading book: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _repository.delete(id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure(
        message: 'Error deleting book: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
