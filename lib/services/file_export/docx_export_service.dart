import 'dart:io';
import 'package:docx/docx.dart' as docx;
import '../../core/errors/exceptions.dart';
import 'file_export_service.dart';

class DocxExportService extends FileExportService {
  @override
  Future<String> export({
    required String title,
    required String? author,
    required String translatedText,
    required String outputDir,
    required Map<String, dynamic>? originalMetadata,
  }) async {
    try {
      final sanitizedTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final outputPath =
          '${outputDir}${Platform.pathSeparator}${sanitizedTitle}_es.docx';

      final doc = docx.Document();
      doc.add(docx.Paragraph(text: title, heading: docx.Heading.heading1));
      if (author != null) {
        doc.add(docx.Paragraph(
          text: 'Autor: $author',
          spacing: docx.Spacing(before: 200, after: 400),
        ));
      }

      final paragraphs = translatedText.split('\n\n');
      for (final para in paragraphs) {
        if (para.trim().isNotEmpty) {
          doc.add(docx.Paragraph(text: para.trim()));
        }
      }

      final bytes = doc.save();
      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting DOCX: $e');
    }
  }

  @override
  bool supportsFormat(String format) => format == 'docx';
}
