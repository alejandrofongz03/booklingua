import 'dart:convert';
import 'package:http/http.dart' as http;
import 'translation_engine.dart';

class DeepLTranslationEngine extends TranslationEngine {
  final String apiKey;
  final http.Client _client;

  DeepLTranslationEngine({required this.apiKey})
      : _client = http.Client();

  @override
  String get name => 'DeepL';

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _client.close();
    _initialized = false;
  }

  @override
  bool get isInitialized => _initialized;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? quality,
  }) async {
    if (text.trim().isEmpty) return '';

    final response = await _client.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {
        'Authorization': 'DeepL-Auth-Key $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': [text],
        'source_lang': sourceLanguage.toUpperCase(),
        'target_lang': targetLanguage.toUpperCase(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translations = data['translations'] as List;
      return translations.first['text'] as String;
    }

    throw Exception('DeepL API error: ${response.statusCode}');
  }
}
