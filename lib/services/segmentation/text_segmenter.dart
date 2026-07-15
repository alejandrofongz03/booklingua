import '../../core/constants/app_constants.dart';
import '../../core/utils/text_utils.dart';
import '../../data/models/book_chunk_model.dart';

class TextSegmenter {
  final int maxChunkSize;

  TextSegmenter({this.maxChunkSize = AppConstants.maxChunkSize});

  List<BookChunkModel> segment({
    required String bookId,
    required String text,
  }) {
    final chunks = TextUtils.splitIntoChunks(text, maxChunkSize);
    return chunks.asMap().entries.map((entry) {
      return BookChunkModel(
        id: '${bookId}_chunk_${entry.key}',
        bookId: bookId,
        index: entry.key,
        sourceText: entry.value,
      );
    }).toList();
  }

  String reassemble(List<BookChunkModel> chunks) {
    chunks.sort((a, b) => a.index.compareTo(b.index));
    return chunks.map((c) => c.translatedText ?? c.sourceText).join('\n\n');
  }

  List<BookChunkModel> getPendingChunks(List<BookChunkModel> chunks) {
    return chunks.where((c) => !c.isTranslated).toList();
  }

  List<BookChunkModel> getCompletedChunks(List<BookChunkModel> chunks) {
    return chunks.where((c) => c.isTranslated).toList();
  }
}
