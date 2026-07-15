import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'booklingua.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        format TEXT NOT NULL,
        file_path TEXT NOT NULL,
        cover_image_path TEXT,
        file_size INTEGER NOT NULL DEFAULT 0,
        total_chunks INTEGER NOT NULL DEFAULT 0,
        translated_chunks INTEGER NOT NULL DEFAULT 0,
        total_words INTEGER NOT NULL DEFAULT 0,
        translated_words INTEGER NOT NULL DEFAULT 0,
        translation_status TEXT NOT NULL DEFAULT 'pending',
        source_language TEXT NOT NULL DEFAULT 'en',
        target_language TEXT NOT NULL DEFAULT 'es',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        output_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE book_chunks (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        chunk_index INTEGER NOT NULL,
        source_text TEXT NOT NULL,
        translated_text TEXT,
        is_translated INTEGER NOT NULL DEFAULT 0,
        format_metadata TEXT,
        FOREIGN KEY (book_id) REFERENCES books(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE translation_progress (
        book_id TEXT PRIMARY KEY,
        total_chunks INTEGER NOT NULL,
        completed_chunks INTEGER NOT NULL DEFAULT 0,
        failed_chunks INTEGER NOT NULL DEFAULT 0,
        total_words INTEGER NOT NULL,
        translated_words INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        start_time TEXT NOT NULL,
        pause_time TEXT,
        elapsed_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES books(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_book_chunks_book_id ON book_chunks(book_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_books_status ON books(translation_status)
    ''');
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
