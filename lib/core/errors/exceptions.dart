class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class FileImportException extends AppException {
  const FileImportException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class FileExportException extends AppException {
  const FileExportException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TextExtractionException extends AppException {
  const TextExtractionException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TranslationException extends AppException {
  const TranslationException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class FormatNotSupportedException extends AppException {
  const FormatNotSupportedException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
