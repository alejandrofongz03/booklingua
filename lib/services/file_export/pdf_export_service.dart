import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/errors/exceptions.dart';
import 'file_export_service.dart';

class PdfExportService extends FileExportService {
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
          '${outputDir}${Platform.pathSeparator}${sanitizedTitle}_es.pdf';

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 24)),
            ),
            if (author != null)
              pw.Paragraph(
                text: 'Autor: $author',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            pw.SizedBox(height: 20),
            ..._buildParagraphs(translatedText),
          ],
        ),
      );

      final bytes = await doc.save();
      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting PDF: $e');
    }
  }

  List<pw.Widget> _buildParagraphs(String text) {
    final paragraphs = text.split('\n\n');
    return paragraphs
        .where((p) => p.trim().isNotEmpty)
        .map((p) => pw.Paragraph(
              text: p.trim(),
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
            ))
        .toList();
  }

  @override
  bool supportsFormat(String format) => format == 'pdf';
}
