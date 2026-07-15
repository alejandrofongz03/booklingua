import 'package:sqflite/sqflite.dart';
import '../../domain/models/book.dart';
import 'app_database.dart';

class BooksTable {
  static const String tableName = 'books';

  static const String id = 'id';
  static const String title = 'title';
  static const String author = 'author';
  static const String format = 'format';
  static const String filePath = 'file_path';
  static const String coverImagePath = 'cover_image_path';
  static const String fileSize = 'file_size';
  static const String totalChunks = 'total_chunks';
  static const String translatedChunks = 'translated_chunks';
  static const String totalWords = 'total_words';
  static const String translatedWords = 'translated_words';
  static const String translationStatus = 'translation_status';
  static const String sourceLanguage = 'source_language';
  static const String targetLanguage = 'target_language';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String outputPath = 'output_path';

  static Future<Database> get _db => AppDatabase.database;

  static Book _fromMap(Map<String, dynamic> map) {
    return Book(
      id: map[id] as String,
      title: map[title] as String,
      author: map[author] as String?,
      format: BookFormat.values.firstWhere((f) => f.name == map[format]),
      filePath: map[filePath] as String,
      coverImagePath: map[coverImagePath] as String?,
      fileSize: map[fileSize] as int,
      totalChunks: map[totalChunks] as int? ?? 0,
      translatedChunks: map[translatedChunks] as int? ?? 0,
      totalWords: map[totalWords] as int? ?? 0,
      translatedWords: map[translatedWords] as int? ?? 0,
      translationStatus: TranslationStatus.values.firstWhere(
        (s) => s.name == map[translationStatus],
      ),
      sourceLanguage: map[sourceLanguage] as String? ?? 'en',
      targetLanguage: map[targetLanguage] as String? ?? 'es',
      createdAt: DateTime.parse(map[createdAt] as String),
      updatedAt: map[updatedAt] != null
          ? DateTime.parse(map[updatedAt] as String)
          : null,
      outputPath: map[outputPath] as String?,
    );
  }

  static Map<String, dynamic> _toMap(Book book) {
    return {
      id: book.id,
      title: book.title,
      author: book.author,
      format: book.format.name,
      filePath: book.filePath,
      coverImagePath: book.coverImagePath,
      fileSize: book.fileSize,
      totalChunks: book.totalChunks,
      translatedChunks: book.translatedChunks,
      totalWords: book.totalWords,
      translatedWords: book.translatedWords,
      translationStatus: book.translationStatus.name,
      sourceLanguage: book.sourceLanguage,
      targetLanguage: book.targetLanguage,
      createdAt: book.createdAt.toIso8601String(),
      updatedAt: book.updatedAt?.toIso8601String(),
      outputPath: book.outputPath,
    };
  }

  static Future<List<Book>> getAll() async {
    final db = await _db;
    final maps = await db.query(tableName, orderBy: '$createdAt DESC');
    return maps.map(_fromMap).toList();
  }

  static Stream<List<Book>> watchAll() {
    return Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => getAll());
  }

  static Future<Book?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(tableName, where: '$id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  static Future<void> insert(Book book) async {
    final db = await _db;
    await db.insert(tableName, _toMap(book),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> update(Book book) async {
    final db = await _db;
    final map = _toMap(book.copyWith(updatedAt: DateTime.now()));
    await db.update(tableName, map, where: 'id = ?', whereArgs: [book.id]);
  }

  static Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Book>> search(String query) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: '$title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map(_fromMap).toList();
  }

  static Future<List<Book>> getByStatus(TranslationStatus status) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: '$translationStatus = ?',
      whereArgs: [status.name],
    );
    return maps.map(_fromMap).toList();
  }

  static Future<int> getBookCount() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int;
  }
}

class BookChunksTable {
  static const String tableName = 'book_chunks';

  static const String id = 'id';
  static const String bookId = 'book_id';
  static const String chunkIndex = 'chunk_index';
  static const String sourceText = 'source_text';
  static const String translatedText = 'translated_text';
  static const String isTranslated = 'is_translated';
  static const String formatMetadata = 'format_metadata';

  static Future<Database> get _db => AppDatabase.database;

  static Future<List<Map<String, dynamic>>> getByBookId(String bookId) async {
    final db = await _db;
    return await db.query(
      tableName,
      where: '$bookId = ?',
      whereArgs: [bookId],
      orderBy: '$chunkIndex ASC',
    );
  }

  static Future<void> insert(Map<String, dynamic> map) async {
    final db = await _db;
    await db.insert(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> update(Map<String, dynamic> map) async {
    final db = await _db;
    await db.update(tableName, map, where: 'id = ?', whereArgs: [map[id]]);
  }

  static Future<void> deleteByBookId(String bookId) async {
    final db = await _db;
    await db.delete(tableName, where: '$bookId = ?', whereArgs: [bookId]);
  }
}

class TranslationProgressTable {
  static const String tableName = 'translation_progress';

  static const String bookId = 'book_id';
  static const String totalChunks = 'total_chunks';
  static const String completedChunks = 'completed_chunks';
  static const String failedChunks = 'failed_chunks';
  static const String totalWords = 'total_words';
  static const String translatedWords = 'translated_words';
  static const String status = 'status';
  static const String startTime = 'start_time';
  static const String pauseTime = 'pause_time';
  static const String elapsedSeconds = 'elapsed_seconds';

  static Future<Database> get _db => AppDatabase.database;

  static Future<Map<String, dynamic>?> getByBookId(String id) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: '$bookId = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  static Future<void> upsert(Map<String, dynamic> map) async {
    final db = await _db;
    await db.insert(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteByBookId(String id) async {
    final db = await _db;
    await db.delete(tableName, where: '$bookId = ?', whereArgs: [id]);
  }
}
