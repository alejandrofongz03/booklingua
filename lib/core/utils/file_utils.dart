import 'dart:io';

class FileUtils {
  FileUtils._();

  static final List<String> _epubExtensions = ['epub'];
  static final List<String> _pdfExtensions = ['pdf'];
  static final List<String> _docxExtensions = ['docx'];
  static final List<String> _txtExtensions = ['txt'];

  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  static String detectFormat(String filePath) {
    final ext = getFileExtension(filePath);
    if (_epubExtensions.contains(ext)) return 'epub';
    if (_pdfExtensions.contains(ext)) return 'pdf';
    if (_docxExtensions.contains(ext)) return 'docx';
    if (_txtExtensions.contains(ext)) return 'txt';
    return 'unknown';
  }

  static bool isFormatSupported(String filePath) {
    return detectFormat(filePath) != 'unknown';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static String sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  static String generateOutputFileName(String inputPath, String targetFormat) {
    final base = inputPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    return '${base}_es.$targetFormat';
  }
}
