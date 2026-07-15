import 'dart:io';
import '../../core/errors/exceptions.dart';
import '../../core/utils/file_utils.dart';
import '../../domain/models/book.dart';

abstract class FileImportService {
  Future<ImportedBook> import(String filePath);
  bool supportsFormat(String format);
}

class ImportedBook {
  final String title;
  final String? author;
  final String? coverImagePath;
  final String filePath;
  final BookFormat format;
  final String rawText;
  final Map<String, dynamic> metadata;

  const ImportedBook({
    required this.title,
    this.author,
    this.coverImagePath,
    required this.filePath,
    required this.format,
    required this.rawText,
    this.metadata = const {},
  });
}

class FileImportServiceFactory {
  final List<FileImportService> _importers;

  FileImportServiceFactory(this._importers);

  FileImportService getImporter(String format) {
    for (final importer in _importers) {
      if (importer.supportsFormat(format)) return importer;
    }
    throw FormatNotSupportedException(message: 'Format not supported: $format');
  }

  Future<ImportedBook> import(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileImportException(message: 'File not found: $filePath');
    }
    final format = FileUtils.detectFormat(filePath);
    final importer = getImporter(format);
    return importer.import(filePath);
  }
}
