import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
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

      final archive = Archive();

      final mimetypeBytes = utf8.encode('application/epub+zip');
      final mimetypeFile = ArchiveFile('mimetype', mimetypeBytes.length, mimetypeBytes);
      archive.addFile(mimetypeFile);

      final containerXml = _buildContainerXml();
      archive.addFile(ArchiveFile(
        'META-INF/container.xml', 0, utf8.encode(containerXml)));

      final contentOpf = _buildOpf(title, author, chapters.length);
      archive.addFile(ArchiveFile(
        'OEBPS/content.opf', 0, utf8.encode(contentOpf)));

      for (int i = 0; i < chapters.length; i++) {
        final chapterXhtml = _buildChapter(i + 1, chapters[i]);
        archive.addFile(ArchiveFile(
          'OEBPS/chapter${i + 1}.xhtml', 0,
          utf8.encode(chapterXhtml)));
      }

      final navXhtml = _buildNav(title, chapters.length);
      archive.addFile(ArchiveFile(
        'OEBPS/nav.xhtml', 0, utf8.encode(navXhtml)));

      final bytes = ZipEncoder().encode(archive);
      if (bytes == null) {
        throw FileExportException(message: 'Error encoding EPUB archive');
      }

      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting EPUB: $e');
    }
  }

  String _buildContainerXml() {
    final doc = XmlDocument([
      XmlElement(XmlName('container'), [
        XmlAttribute(XmlName('version'), '1.0'),
        XmlAttribute(XmlName('xmlns'),
            'urn:oasis:names:tc:opendocument:xmlns:container'),
      ], [
        XmlElement(XmlName('rootfiles'), [
          XmlElement(XmlName('rootfile'), [
            XmlAttribute(XmlName('full-path'), 'OEBPS/content.opf'),
            XmlAttribute(XmlName('media-type'),
                'application/oebps-package+xml'),
          ]),
        ]),
      ]),
    ]);
    return '<?xml version="1.0" encoding="UTF-8"?>\n${doc.toXmlString()}';
  }

  String _buildOpf(String title, String? author, int chapterCount) {
    final manifest = StringBuffer();
    manifest.writeln('    <item id="nav" href="nav.xhtml" '
        'media-type="application/xhtml+xml" properties="nav"/>');
    for (int i = 0; i < chapterCount; i++) {
      manifest.writeln('    <item id="chapter${i + 1}" '
          'href="chapter${i + 1}.xhtml" media-type="application/xhtml+xml"/>');
    }

    final spine = StringBuffer();
    for (int i = 0; i < chapterCount; i++) {
      spine.writeln('    <itemref idref="chapter${i + 1}"/>');
    }

    return '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0"
    unique-identifier="book-id">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">urn:uuid:${DateTime.now().millisecondsSinceEpoch}</dc:identifier>
    <dc:title>$title (Español)</dc:title>
    ${author != null ? '<dc:creator>$author</dc:creator>' : ''}
    <dc:language>es</dc:language>
    <meta property="dcterms:modified">${DateTime.now().toUtc().toIso8601String()}Z</meta>
  </metadata>
  <manifest>
$manifest  </manifest>
  <spine>
$spine  </spine>
</package>''';
  }

  String _buildChapter(int number, String content) {
    final escaped = _escapeXml(content);
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Capítulo $number</title></head>
<body>
  <h1>Capítulo $number</h1>
  ${escaped.split('\n\n').map((p) => p.trim()).where((p) => p.isNotEmpty).map((p) => '  <p>$p</p>').join('\n')}
</body>
</html>''';
  }

  String _buildNav(String title, int chapterCount) {
    final items = StringBuffer();
    for (int i = 0; i < chapterCount; i++) {
      items.writeln('    <li><a href="chapter${i + 1}.xhtml">Capítulo ${i + 1}</a></li>');
    }

    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head><title>$title</title></head>
<body>
  <nav epub:type="toc">
    <h1>Tabla de contenidos</h1>
    <ol>
$items    </ol>
  </nav>
</body>
</html>''';
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
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
