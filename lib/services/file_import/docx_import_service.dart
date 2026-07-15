import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/book.dart';
import 'file_import_service.dart';

class DocxImportService extends FileImportService {
  @override
  Future<ImportedBook> import(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final docFile = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
      );
      final docXml = XmlDocument.parse(String.fromCharCodes(docFile.content));

      final textBuffer = StringBuffer();
      final paragraphs = docXml.findAllElements('w:p');
      for (final paragraph in paragraphs) {
        final texts = paragraph.findAllElements('w:t');
        for (final text in texts) {
          textBuffer.write(text.innerText);
        }
        textBuffer.writeln();
      }

      final fileName = filePath.split('\\').last.split('/').last;
      final title = fileName.replaceAll('.docx', '').replaceAll('.DOCX', '');

      return ImportedBook(
        title: title,
        filePath: filePath,
        format: BookFormat.docx,
        rawText: textBuffer.toString(),
        metadata: {'paragraphs': paragraphs.length},
      );
    } catch (e) {
      throw TextExtractionException(
        message: 'Error importing DOCX file: $e',
      );
    }
  }

  @override
  bool supportsFormat(String format) => format == 'docx';
}
