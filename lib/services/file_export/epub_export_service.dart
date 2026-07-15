import 'dart:io';
import 'package:epubx/epubx.dart';
import '../../core/errors/exceptions.dart';
import 'file_export_service.dart';

class EpubExportService extends FileExportService {
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
          '${outputDir}${Platform.pathSeparator}${sanitizedTitle}_es.epub';

      final chapters = _splitIntoChapters(translatedText);

      final builder = EpubBuilder();
      builder.withTitle('$title (Español)');
      if (author != null) {
        builder.withCreator(author);
      }
      builder.withLanguage('es');

      for (int i = 0; i < chapters.length; i++) {
        builder.withChapter(
          EpubChapterBuilder()
            ..withTitle('Capítulo ${i + 1}')
            ..withContent(chapters[i]),
        );
      }

      final epubBytes = builder.build();
      await File(outputPath).writeAsBytes(epubBytes);
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting EPUB: $e');
    }
  }

  List<String> _splitIntoChapters(String text) {
    final chapters = <String>[];
    final lines = text.split('\n');
    var currentChapter = StringBuffer();

    for (final line in lines) {
      if (line.trim().toLowerCase().startsWith('chapter') ||
          line.trim().toLowerCase().startsWith('capítulo') ||
          (line.trim().startsWith('#') && line.trim().length > 1)) {
        if (currentChapter.isNotEmpty) {
          chapters.add(currentChapter.toString().trim());
          currentChapter = StringBuffer();
        }
      }
      currentChapter.writeln(line);
    }

    if (currentChapter.isNotEmpty) {
      chapters.add(currentChapter.toString().trim());
    }

    if (chapters.isEmpty) {
      chapters.add(text);
    }

    return chapters;
  }

  @override
  bool supportsFormat(String format) => format == 'epub';
}
