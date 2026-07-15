import 'dart:io';
import '../../core/errors/exceptions.dart';
import '../../domain/models/book.dart';
import 'file_import_service.dart';

class TxtImportService extends FileImportService {
  @override
  Future<ImportedBook> import(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final fileName = filePath.split('\\').last.split('/').last;
      final title = fileName.replaceAll('.txt', '').replaceAll('.TXT', '');

      return ImportedBook(
        title: title,
        filePath: filePath,
        format: BookFormat.txt,
        rawText: content,
        metadata: {'encoding': 'utf-8'},
      );
    } catch (e) {
      throw TextExtractionException(
        message: 'Error importing TXT file: $e',
      );
    }
  }

  @override
  bool supportsFormat(String format) => format == 'txt';
}
