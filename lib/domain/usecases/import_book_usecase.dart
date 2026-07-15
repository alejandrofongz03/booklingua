import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

class ImportBookUseCase {
  final BookRepository _repository;

  ImportBookUseCase(this._repository);

  Future<Either<Failure, Book>> call({
    required String filePath,
    required String title,
    String? author,
    String? coverImagePath,
  }) async {
    try {
      final format = _detectFormat(filePath);
      final book = Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        author: author,
        format: format,
        filePath: filePath,
        coverImagePath: coverImagePath,
        fileSize: 0,
        createdAt: DateTime.now(),
      );
      final saved = await _repository.save(book);
      return Right(saved);
    } catch (e, stackTrace) {
      return Left(FileImportFailure(
        message: 'Error importing book: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  BookFormat _detectFormat(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'epub':
        return BookFormat.epub;
      case 'pdf':
        return BookFormat.pdf;
      case 'docx':
        return BookFormat.docx;
      case 'txt':
        return BookFormat.txt;
      default:
        throw UnsupportedError('Unsupported format: $ext');
    }
  }
}
