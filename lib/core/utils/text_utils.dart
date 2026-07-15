class TextUtils {
  TextUtils._();

  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  static int countCharacters(String text) {
    return text.length;
  }

  static int countSentences(String text) {
    if (text.trim().isEmpty) return 0;
    final matches = RegExp(r'[.!?]+').allMatches(text);
    return matches.length > 0 ? matches.length : 1;
  }

  static List<String> splitIntoChunks(String text, int maxChunkSize) {
    if (text.length <= maxChunkSize) return [text];

    final chunks = <String>[];
    int start = 0;

    while (start < text.length) {
      int end = start + maxChunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      int breakPoint = text.lastIndexOf('\n\n', end);
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf('\n', end);
      }
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf('. ', end);
      }
      if (breakPoint <= start) {
        breakPoint = text.lastIndexOf(' ', end);
      }
      if (breakPoint <= start) {
        breakPoint = end;
      } else {
        breakPoint++;
      }

      chunks.add(text.substring(start, breakPoint));
      start = breakPoint;
    }

    return chunks;
  }

  static String detectLanguage(String text) {
    final enChars = RegExp(r'[a-zA-Z]').allMatches(text).length;
    final esChars = RegExp(r'[a-záéíóúüñA-ZÁÉÍÓÚÜÑ]').allMatches(text).length;

    if (esChars > enChars * 1.2) return 'es';
    return 'en';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static double estimateReadingTimeMinutes(String text, {int wordsPerMinute = 200}) {
    final wordCount = countWords(text);
    return wordCount / wordsPerMinute;
  }
}
