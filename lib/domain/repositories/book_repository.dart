import '../models/book.dart';

abstract class BookRepository {
  Stream<List<Book>> watchAll();
  Future<List<Book>> getAll();
  Future<Book?> getById(String id);
  Future<Book> save(Book book);
  Future<Book> update(Book book);
  Future<void> delete(String id);
  Future<List<Book>> search(String query);
  Future<List<Book>> getByStatus(TranslationStatus status);
  Future<int> getBookCount();
}
