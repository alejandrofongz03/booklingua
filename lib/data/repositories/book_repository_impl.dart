import '../../domain/models/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../database/dao/book_dao.dart';

class BookRepositoryImpl implements BookRepository {
  final BookDao _bookDao;

  BookRepositoryImpl(this._bookDao);

  @override
  Stream<List<Book>> watchAll() => _bookDao.watchAll();

  @override
  Future<List<Book>> getAll() => _bookDao.getAll();

  @override
  Future<Book?> getById(String id) => _bookDao.getById(id);

  @override
  Future<Book> save(Book book) => _bookDao.save(book);

  @override
  Future<Book> update(Book book) => _bookDao.update(book);

  @override
  Future<void> delete(String id) => _bookDao.delete(id);

  @override
  Future<List<Book>> search(String query) => _bookDao.search(query);

  @override
  Future<List<Book>> getByStatus(TranslationStatus status) =>
      _bookDao.getByStatus(status);

  @override
  Future<int> getBookCount() => _bookDao.getBookCount();
}
