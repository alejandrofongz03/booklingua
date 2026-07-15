import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, code, stackTrace];
}

class FileImportFailure extends Failure {
  const FileImportFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class FileExportFailure extends Failure {
  const FileExportFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TextExtractionFailure extends Failure {
  const TextExtractionFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class TranslationFailure extends Failure {
  const TranslationFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class SettingsFailure extends Failure {
  const SettingsFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}
