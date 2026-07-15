import 'dart:io';
import 'package:epubx/epubx.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/book.dart';
import 'file_import_service.dart';

class EpubImportService extends FileImportService {
  @override
  Future<ImportedBook> import(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final epubDoc = await EpubDocument.fromBytes(bytes);

      final title = epubDoc.Title?.firstOrNull ?? 'Unknown Title';
      final author = epubDoc.Creator?.firstOrNull;
      final coverImage = epubDoc.Cover?.firstOrNull;

      final chapters = epubDoc.Chapters ?? [];
      final textBuffer = StringBuffer();

      for (final chapter in chapters) {
        if (chapter.Content != null) {
          textBuffer.writeln(chapter.Content);
        }
      }

      return ImportedBook(
        title: title,
        author: author,
        filePath: filePath,
        format: BookFormat.epub,
        rawText: textBuffer.toString(),
        metadata: {
          'cover': coverImage?.data,
          'chapters': chapters.length,
        },
      );
    } catch (e) {
      throw TextExtractionException(
        message: 'Error importing EPUB file: $e',
      );
    }
  }

  @override
  bool supportsFormat(String format) => format == 'epub';
}
