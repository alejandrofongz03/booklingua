import '../../data/models/book_chunk_model.dart';

class FormatPreserver {
  final Map<String, String Function(String)> _preservationRules = {};

  void addRule(String name, String Function(String) rule) {
    _preservationRules[name] = rule;
  }

  String preserveFormatting(String text) {
    String result = text;
    for (final rule in _preservationRules.values) {
      result = rule(result);
    }
    return result;
  }

  String restoreFormatting(String text) {
    return text;
  }

  Map<String, dynamic> extractMetadata(String text) {
    final metadata = <String, dynamic>{};

    final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$', multiLine: true)
        .allMatches(text);
    if (headingMatch.isNotEmpty) {
      metadata['hasHeadings'] = true;
      metadata['headingCount'] = headingMatch.length;
    }

    final listMatch =
        RegExp(r'^[\s]*[-*+]\s+', multiLine: true).allMatches(text);
    if (listMatch.isNotEmpty) {
      metadata['hasLists'] = true;
      metadata['listCount'] = listMatch.length;
    }

    final boldMatch = RegExp(r'\*\*(.+?)\*\*').allMatches(text);
    if (boldMatch.isNotEmpty) {
      metadata['hasBold'] = true;
    }

    final italicMatch = RegExp(r'\*(.+?)\*').allMatches(text);
    if (italicMatch.isNotEmpty) {
      metadata['hasItalic'] = true;
    }

    return metadata;
  }

  BookChunkModel preserveChunkFormatting(BookChunkModel chunk) {
    final preservedText = preserveFormatting(chunk.sourceText);
    return chunk.copyWith(
      sourceText: preservedText,
      formatMetadata: extractMetadata(chunk.sourceText),
    );
  }

  String applyFormattingToTranslation(
    String translatedText,
    Map<String, dynamic>? formatMetadata,
  ) {
    String result = translatedText;
    if (formatMetadata == null) return result;
    return result;
  }
}
