import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
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

      final paragraphs = translatedText.split('\n\n');
      final bodyXml = XmlDocument([
        XmlElement(XmlName('w:document'), [
          XmlAttribute(XmlName('xmlns:w'), 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'),
          XmlAttribute(XmlName('xmlns:r'), 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'),
        ], [
          XmlElement(XmlName('w:body'), [
            _titleParagraph(title),
            if (author != null) _authorParagraph(author),
            ...paragraphs.where((p) => p.trim().isNotEmpty).map(_textParagraph),
          ]),
        ]),
      ]);

      final contentTypesXml = XmlDocument([
        XmlElement(XmlName('Types'), [
          XmlAttribute(XmlName('xmlns'), 'http://schemas.openxmlformats.org/package/2006/content-types'),
        ], [
          _defaultOverride('rels', 'application/vnd.openxmlformats-package.relationships+xml'),
          _defaultOverride('xml', 'application/xml'),
          _override('/word/document.xml', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'),
        ]),
      ]);

      final relsXml = XmlDocument([
        XmlElement(XmlName('Relationships'), [
          XmlAttribute(XmlName('xmlns'), 'http://schemas.openxmlformats.org/package/2006/relationships'),
        ], [
          _relationship('rId1', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument', 'word/document.xml'),
        ]),
      ]);

      final docRelsXml = XmlDocument([
        XmlElement(XmlName('Relationships'), [
          XmlAttribute(XmlName('xmlns'), 'http://schemas.openxmlformats.org/package/2006/relationships'),
        ], []),
      ]);

      final archive = Archive();
      archive.addFile(ArchiveFile('word/document.xml', 0, utf8.encode(bodyXml.toXmlString())));
      archive.addFile(ArchiveFile('[Content_Types].xml', 0, utf8.encode(contentTypesXml.toXmlString())));
      archive.addFile(ArchiveFile('_rels/.rels', 0, utf8.encode(relsXml.toXmlString())));
      archive.addFile(ArchiveFile('word/_rels/document.xml.rels', 0, utf8.encode(docRelsXml.toXmlString())));

      final bytes = ZipEncoder().encode(archive);
      if (bytes == null) {
        throw FileExportException(message: 'Error encoding DOCX archive');
      }

      await File(outputPath).writeAsBytes(bytes);
      return outputPath;
    } catch (e) {
      throw FileExportException(message: 'Error exporting DOCX: $e');
    }
  }

  XmlElement _titleParagraph(String text) {
    return XmlElement(XmlName('w:p'), [
      _paragraphProperties(24),
      XmlElement(XmlName('w:r'), [
        XmlElement(XmlName('w:rPr'), [
          XmlElement(XmlName('w:b')),
          XmlElement(XmlName('w:sz'), [XmlAttribute(XmlName('w:val'), '48')]),
        ]),
        XmlElement(XmlName('w:t'), [XmlText(text)]),
      ]),
    ]);
  }

  XmlElement _authorParagraph(String author) {
    return XmlElement(XmlName('w:p'), [
      _paragraphProperties(20),
      XmlElement(XmlName('w:r'), [
        XmlElement(XmlName('w:rPr'), [
          XmlElement(XmlName('w:i')),
          XmlElement(XmlName('w:sz'), [XmlAttribute(XmlName('w:val'), '24')]),
        ]),
        XmlElement(XmlName('w:t'), [XmlText('Autor: $author')]),
      ]),
    ]);
  }

  XmlElement _textParagraph(String text) {
    return XmlElement(XmlName('w:p'), [
      _paragraphProperties(20),
      XmlElement(XmlName('w:r'), [
        XmlElement(XmlName('w:rPr'), [
          XmlElement(XmlName('w:sz'), [XmlAttribute(XmlName('w:val'), '24')]),
        ]),
        XmlElement(XmlName('w:t'), [XmlText(text)]),
      ]),
    ]);
  }

  XmlElement _paragraphProperties(int spacingAfter) {
    return XmlElement(XmlName('w:pPr'), [
      XmlElement(XmlName('w:spacing'), [
        XmlAttribute(XmlName('w:after'), spacingAfter.toString()),
        XmlAttribute(XmlName('w:line'), '360'),
        XmlAttribute(XmlName('w:lineRule'), 'auto'),
      ]),
    ]);
  }

  XmlElement _defaultOverride(String extension, String contentType) {
    return XmlElement(XmlName('Default'), [
      XmlAttribute(XmlName('Extension'), extension),
      XmlAttribute(XmlName('ContentType'), contentType),
    ]);
  }

  XmlElement _override(String partName, String contentType) {
    return XmlElement(XmlName('Override'), [
      XmlAttribute(XmlName('PartName'), partName),
      XmlAttribute(XmlName('ContentType'), contentType),
    ]);
  }

  XmlElement _relationship(String id, String type, String target) {
    return XmlElement(XmlName('Relationship'), [
      XmlAttribute(XmlName('Id'), id),
      XmlAttribute(XmlName('Type'), type),
      XmlAttribute(XmlName('Target'), target),
    ]);
  }

  @override
  bool supportsFormat(String format) => format == 'docx';
}
