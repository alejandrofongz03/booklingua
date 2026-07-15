import '../../domain/models/book.dart';
import '../database/tables.dart';

class BookDao {
  Stream<List<Book>> watchAll() => BooksTable.watchAll();

  Future<List<Book>> getAll() => BooksTable.getAll();

  Future<Book?> getById(String id) => BooksTable.getById(id);

  Future<Book> save(Book book) async {
    await BooksTable.insert(book);
    return book;
  }

  Future<Book> update(Book book) async {
    await BooksTable.update(book);
    return book;
  }

  Future<void> delete(String id) => BooksTable.delete(id);

  Future<List<Book>> search(String query) => BooksTable.search(query);

  Future<List<Book>> getByStatus(TranslationStatus status) =>
      BooksTable.getByStatus(status);

  Future<int> getBookCount() => BooksTable.getBookCount();
}
