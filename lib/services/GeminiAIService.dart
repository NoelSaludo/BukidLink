import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A small wrapper to call a Gemini-like REST endpoint.
///
/// Notes:
/// - The API URL and key are read from environment variables:
///   - `GEMINI_API_URL` (full URL to POST prompts)
///   - `GEMINI_API_KEY` (authorization token)
/// - Do not populate the API key in source code; keep it in `.env`.
class GeminiAIService {
  static final GeminiAIService shared = GeminiAIService._internal();
  GeminiAIService._internal();
  factory GeminiAIService() => shared;

  final String? _apiUrl = dotenv.env['GEMINI_API_URL'];
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  /// Given historical orders (list of orders where each order is a list of product ids)
  /// ask the model to suggest up to [limit] product ids to recommend.
  ///
  /// [catalogIds] should contain the available product ids in the catalog so the
  /// returned ids can be filtered/validated.
  Future<List<String>> suggestProductIdsFromOrders({
    required List<List<String>> orders,
    required List<String> catalogIds,
    String? currentProductId,
    int limit = 5,
  }) async {
    if (_apiUrl == null || _apiUrl.isEmpty) {
      // API URL not configured — return empty so caller can gracefully fallback.
      return [];
    }

    final promptBuffer = StringBuffer();
    promptBuffer.writeln(
      'You are an assistant that analyzes purchase history to recommend products that are frequently bought together.',
    );
    promptBuffer.writeln(
      'Each order is provided as a list of product IDs. Using the full dataset of orders below, compute how often other product IDs appear in the same order as the CURRENT product ID.',
    );
    promptBuffer.writeln(
      'Produce a ranked list of product IDs ordered by descending co-purchase frequency (most commonly bought together first). If two products tie, order them by overall occurrence frequency across all orders.',
    );
    promptBuffer.writeln('Orders:');
    for (var o in orders) {
      if (o.isEmpty) continue;
      promptBuffer.writeln('- [${o.join(', ')}]');
    }
    promptBuffer.writeln('CURRENT_PRODUCT_ID: ${currentProductId ?? 'NONE'}');
    promptBuffer.writeln(
      'Return up to $limit product ids, separated by commas. Return only product ids and nothing else.',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': promptBuffer.toString()},
          ],
        },
      ],
      'generationConfig': {'maxOutputTokens': 512, 'candidateCount': 1},
    };

    final body = json.encode(requestBody);

    try {
      final headers = {'Content-Type': 'application/json'};
      // Use the X-goog-api-key header as required by the Generative Language REST API
      if (_apiKey != null && _apiKey.isNotEmpty) {
        headers['X-goog-api-key'] = _apiKey;
      }

      final resp = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return [];
      }

      // Try to parse JSON and extract any returned text fields robustly.
      final dynamic parsed = json.decode(resp.body);

      // Prefer structured extraction from candidates -> content -> parts -> text
      final List<String> texts = [];
      if (parsed is Map && parsed['candidates'] is Iterable) {
        for (var cand in parsed['candidates']) {
          try {
            final content = cand['content'];
            if (content is Map && content['parts'] is Iterable) {
              for (var part in content['parts']) {
                if (part is Map && part['text'] is String) {
                  texts.add(part['text']);
                }
              }
            }
          } catch (_) {
            // ignore individual candidate parse errors
          }
        }
      }

      final combined = texts.join(' ');

      // Try to extract product ids by matching tokens that exist in catalogIds.
      final found = <String>[];
      final tokens = RegExp(
        r"[A-Za-z0-9_-]{3,}",
      ).allMatches(combined).map((m) => m.group(0)!).toList();

      for (var t in tokens) {
        if (catalogIds.contains(t) && !found.contains(t)) {
          found.add(t);
          if (found.length >= limit) break;
        }
      }

      return found;
    } catch (e) {
      return [];
    }
  }
}
