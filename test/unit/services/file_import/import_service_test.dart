import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/domain/models/book.dart';
import 'package:booklingua/services/file_import/file_import_service.dart';
import 'package:booklingua/services/file_import/txt_import_service.dart';
import 'package:booklingua/services/file_import/epub_import_service.dart';
import 'package:booklingua/services/file_import/pdf_import_service.dart';
import 'package:booklingua/services/file_import/docx_import_service.dart';

void main() {
  group('TxtImportService', () {
    test('supportsFormat returns true for txt', () {
      final service = TxtImportService();
      expect(service.supportsFormat('txt'), isTrue);
      expect(service.supportsFormat('epub'), isFalse);
    });
  });

  group('EpubImportService', () {
    test('supportsFormat returns true for epub', () {
      final service = EpubImportService();
      expect(service.supportsFormat('epub'), isTrue);
      expect(service.supportsFormat('pdf'), isFalse);
    });
  });

  group('PdfImportService', () {
    test('supportsFormat returns true for pdf', () {
      final service = PdfImportService();
      expect(service.supportsFormat('pdf'), isTrue);
      expect(service.supportsFormat('docx'), isFalse);
    });
  });

  group('DocxImportService', () {
    test('supportsFormat returns true for docx', () {
      final service = DocxImportService();
      expect(service.supportsFormat('docx'), isTrue);
      expect(service.supportsFormat('txt'), isFalse);
    });
  });

  group('FileImportServiceFactory', () {
    test('getImporter returns correct importer', () {
      final importers = [
        TxtImportService(),
        EpubImportService(),
        PdfImportService(),
        DocxImportService(),
      ];
      final factory = FileImportServiceFactory(importers);

      expect(factory.getImporter('txt'), isA<TxtImportService>());
      expect(factory.getImporter('epub'), isA<EpubImportService>());
    });

    test('getImporter throws for unsupported format', () {
      final importers = <FileImportService>[];
      final factory = FileImportServiceFactory(importers);

      expect(
        () => factory.getImporter('exe'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
