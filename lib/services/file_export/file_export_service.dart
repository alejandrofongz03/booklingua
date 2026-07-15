import 'dart:io';
import '../../core/errors/exceptions.dart';

abstract class FileExportService {
  Future<String> export({
    required String title,
    required String? author,
    required String translatedText,
    required String outputDir,
    required Map<String, dynamic>? originalMetadata,
  });
  bool supportsFormat(String format);
}

class FileExportServiceFactory {
  final List<FileExportService> _exporters;

  FileExportServiceFactory(this._exporters);

  FileExportService getExporter(String format) {
    for (final exporter in _exporters) {
      if (exporter.supportsFormat(format)) return exporter;
    }
    throw FormatNotSupportedException(message: 'Export format not supported: $format');
  }
}
