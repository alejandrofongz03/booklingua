import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/core/utils/file_utils.dart';

void main() {
  group('FileUtils', () {
    test('getFileExtension returns correct extension', () {
      expect(FileUtils.getFileExtension('book.epub'), 'epub');
      expect(FileUtils.getFileExtension('book.pdf'), 'pdf');
      expect(FileUtils.getFileExtension('book.docx'), 'docx');
      expect(FileUtils.getFileExtension('book.txt'), 'txt');
    });

    test('detectFormat identifies formats correctly', () {
      expect(FileUtils.detectFormat('book.epub'), 'epub');
      expect(FileUtils.detectFormat('book.pdf'), 'pdf');
      expect(FileUtils.detectFormat('book.docx'), 'docx');
      expect(FileUtils.detectFormat('book.txt'), 'txt');
      expect(FileUtils.detectFormat('book.unknown'), 'unknown');
    });

    test('isFormatSupported returns true for supported formats', () {
      expect(FileUtils.isFormatSupported('book.epub'), isTrue);
      expect(FileUtils.isFormatSupported('book.pdf'), isTrue);
      expect(FileUtils.isFormatSupported('book.docx'), isTrue);
      expect(FileUtils.isFormatSupported('book.txt'), isTrue);
      expect(FileUtils.isFormatSupported('book.exe'), isFalse);
    });

    test('formatFileSize formats correctly', () {
      expect(FileUtils.formatFileSize(500), '500 B');
      expect(FileUtils.formatFileSize(2048), '2.0 KB');
      expect(FileUtils.formatFileSize(1048576), '1.0 MB');
    });

    test('sanitizeFileName removes invalid characters', () {
      expect(FileUtils.sanitizeFileName('file:<name>.txt'), 'file_<name>.txt');
    });
  });
}
