import 'dart:io';
import '../../core/errors/exceptions.dart';
import 'file_export_service.dart';

class TxtExportService extends FileExportService {
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
      final outputPath = '${outputDir}${Platform.pathSeparator}${sanitizedTitle}_es.txt';
      final file = File(outputPath);
      final buffer = StringBuffer();

      if (author != null) {
        buffer.writeln('Title: $title');
        buffer.writeln('Author: $author');
        buffer.writeln();
      }

      buffer.write(translatedText);
      await file.writeAsString(buffer.toString());
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting TXT: $e');
    }
  }

  @override
  bool supportsFormat(String format) => format == 'txt';
}
