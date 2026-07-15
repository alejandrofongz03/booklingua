import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/book.dart';
import 'file_import_service.dart';

class PdfImportService extends FileImportService {
  @override
  Future<ImportedBook> import(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final textBuffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final page = document.pages[i];
        textBuffer.writeln(page.text);
      }

      document.dispose();

      final fileName = filePath.split('\\').last.split('/').last;
      final title = fileName.replaceAll('.pdf', '').replaceAll('.PDF', '');

      return ImportedBook(
        title: title,
        filePath: filePath,
        format: BookFormat.pdf,
        rawText: textBuffer.toString(),
        metadata: {'pageCount': document.pages.count},
      );
    } catch (e) {
      throw TextExtractionException(
        message: 'Error importing PDF file: $e',
      );
    }
  }

  @override
  bool supportsFormat(String format) => format == 'pdf';
}
