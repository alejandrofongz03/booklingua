import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/models/book.dart';
import 'file_import_service.dart';

class EpubImportService extends FileImportService {
  @override
  Future<ImportedBook> import(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      final archive = ZipDecoder().decodeBytes(bytes);
      if (archive == null) {
        throw TextExtractionException(message: 'Invalid EPUB file');
      }

      final containerXml = _readFile(archive, 'META-INF/container.xml');
      if (containerXml == null) {
        throw TextExtractionException(message: 'Missing container.xml');
      }

      final containerDoc = XmlDocument.parse(utf8.decode(containerXml));
      final rootfile = containerDoc.findAllElements('rootfile').firstOrNull;
      if (rootfile == null) {
        throw TextExtractionException(message: 'No rootfile in container.xml');
      }
      final opfPath = rootfile.getAttribute('full-path') ?? 'content.opf';

      final opfBytes = _readFile(archive, opfPath);
      if (opfBytes == null) {
        throw TextExtractionException(message: 'Missing OPF file: $opfPath');
      }
      final opfDoc = XmlDocument.parse(utf8.decode(opfBytes));

      final opfDir = opfPath.contains('/')
          ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
          : '';

      final title = _opfMetadata(opfDoc, 'title') ?? 'Unknown Title';
      final author = _opfMetadata(opfDoc, 'creator');
      final coverId = _opfMeta(opfDoc, 'cover');
      final coverHref = coverId != null ? _manifestHref(opfDoc, coverId) : null;
      final coverBytes = coverHref != null
          ? _readFile(archive, '$opfDir$coverHref')
          : null;

      final spineItems = opfDoc
          .findAllElements('itemref')
          .map((e) => e.getAttribute('idref'))
          .where((id) => id != null)
          .cast<String>()
          .toList();

      final textBuffer = StringBuffer();
      var chapterCount = 0;

      for (final itemId in spineItems) {
        final href = _manifestHref(opfDoc, itemId);
        if (href == null) continue;

        final content = _readFile(archive, '$opfDir$href');
        if (content == null) continue;

        final text = _extractXhtmlText(utf8.decode(content));
        if (text.trim().isNotEmpty) {
          textBuffer.writeln(text);
          textBuffer.writeln();
          chapterCount++;
        }
      }

      return ImportedBook(
        title: title,
        author: author,
        filePath: filePath,
        format: BookFormat.epub,
        rawText: textBuffer.toString().trim(),
        metadata: {
          'cover': coverBytes,
          'chapters': chapterCount,
        },
      );
    } catch (e) {
      throw TextExtractionException(
        message: 'Error importing EPUB file: $e',
      );
    }
  }

  List<int>? _readFile(Archive archive, String path) {
    final normalized = path.replaceAll('\\', '/');
    for (final file in archive) {
      if (file.name.replaceAll('\\', '/') == normalized) {
        return file.content;
      }
    }
    return null;
  }

  String? _opfMetadata(XmlDocument doc, String name) {
    final element = doc
        .findAllElements('metadata')
        .expand((m) => m.children)
        .whereType<XmlElement>()
        .firstWhereOrNull(
            (e) => e.localName.toLowerCase() == name.toLowerCase());
    return element?.innerText.trim();
  }

  String? _opfMeta(XmlDocument doc, String name) {
    return doc
        .findAllElements('meta')
        .firstWhereOrNull(
            (e) => e.getAttribute('name')?.toLowerCase() == name.toLowerCase())
        ?.getAttribute('content');
  }

  String? _manifestHref(XmlDocument doc, String id) {
    return doc
        .findAllElements('item')
        .firstWhereOrNull((e) => e.getAttribute('id') == id)
        ?.getAttribute('href');
  }

  String _extractXhtmlText(String xhtml) {
    try {
      final doc = XmlDocument.parse(xhtml);
      final buf = StringBuffer();
      _collectText(doc, buf);
      return buf.toString().trim();
    } catch (_) {
      return xhtml
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }
  }

  void _collectText(XmlNode node, StringBuffer buf) {
    if (node is XmlText) {
      final text = node.value.trim();
      if (text.isNotEmpty) buf.write('$text ');
    } else if (node is XmlElement) {
      if (node.localName.toLowerCase() == 'br' ||
          node.localName.toLowerCase() == 'p' ||
          node.localName.toLowerCase() == 'div') {
        final prev = buf.toString().trimRight();
        if (prev.isNotEmpty && !prev.endsWith('\n')) {
          buf.writeln();
        }
      }
      for (final child in node.children) {
        _collectText(child, buf);
      }
      if (node.localName.toLowerCase() == 'p' ||
          node.localName.toLowerCase() == 'div') {
        buf.writeln();
      }
    }
  }

  @override
  bool supportsFormat(String format) => format == 'epub';
}
