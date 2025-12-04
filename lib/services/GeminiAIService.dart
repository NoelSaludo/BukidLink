import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Result returned by [GeminiAIService.suggestPrice].
class SuggestPriceResult {
  final String message;
  final bool isFarmProduce;
  SuggestPriceResult({required this.message, required this.isFarmProduce});
}

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

  /// Ask the AI to suggest a retail price for a product in the Philippines.
  ///
  /// Returns a [SuggestPriceResult] containing a short message and a boolean
  /// indicating whether the product is a farm produce. If the AI determines
  /// the product is not a farm produce, [isFarmProduce] will be false and the
  /// message should explain that the product is not farm produce.
  Future<SuggestPriceResult> suggestPrice({
    required String name,
    required String unit,
  }) async {
    if (_apiUrl == null || _apiUrl.isEmpty) {
      return SuggestPriceResult(
        message: 'AI service not configured',
        isFarmProduce: false,
      );
    }

    final prompt = StringBuffer();
    prompt.writeln(
      'You are a pricing assistant for Philippine markets (farm-to-consumer, smallholder sellers).',
    );
    prompt.writeln(
      'Given a product name and the selling unit, decide whether the item is a farm produce (e.g., fruits, vegetables, grains, livestock, dairy) or not.',
    );
    prompt.writeln(
      'If it is a farm produce, return a single reasonable suggested retail price in Philippine Peso and nothing else (just the price, you may include the ₱ symbol).',
    );
    prompt.writeln(
      'If it is NOT a farm produce, return the exact sentence: "The product is not a farm produce".',
    );
    prompt.writeln(
      'Use `.` as decimal separator and up to two decimal places.',
    );
    prompt.writeln(
      'IMPORTANT: First, check the Department of Agriculture price monitoring page at https://www.da.gov.ph/price-monitoring/ and, if available, open the latest price monitoring PDF on that site and use the price listed there for this product. If you can access that PDF, prefer its price and include a short note that it came from the DA PDF. If you cannot access the site/PDF, fall back to your best current knowledge and indicate the source as "model estimate" in the returned message.',
    );
    prompt.writeln('Product: $name');
    prompt.writeln('Unit: $unit');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt.toString()},
          ],
        },
      ],
      'generationConfig': {'maxOutputTokens': 64, 'candidateCount': 1},
    };

    final body = json.encode(requestBody);

    try {
      final headers = {'Content-Type': 'application/json'};
      if (_apiKey != null && _apiKey.isNotEmpty) {
        headers['X-goog-api-key'] = _apiKey;
      }

      final resp = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return SuggestPriceResult(
          message: 'AI request failed (status ${resp.statusCode})',
          isFarmProduce: false,
        );
      }

      final dynamic parsed = json.decode(resp.body);
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
            // ignore
          }
        }
      }

      final combined = texts.join(' ').trim();
      final lc = combined.toLowerCase();

      // If AI explicitly says it's not a farm produce, honor that.
      if (lc.contains('the product is not a farm produce') ||
          lc.contains('not a farm produce') ||
          lc.contains('not a farm product') ||
          lc.contains('is not a farm')) {
        return SuggestPriceResult(
          message: 'The product is not a farm produce',
          isFarmProduce: false,
        );
      }

      // Try to extract a peso amount like ₱123.45 or 123.45
      final pesoRegex = RegExp(r'₱\s*([0-9,]+(?:\.[0-9]{1,2})?)');
      final numRegex = RegExp(r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)');

      String? found;
      final pesoMatch = pesoRegex.firstMatch(combined);
      if (pesoMatch != null && pesoMatch.groupCount >= 1) {
        found = pesoMatch.group(1);
      } else {
        final numMatch = numRegex.firstMatch(combined);
        if (numMatch != null && numMatch.groupCount >= 1) {
          found = numMatch.group(1);
        }
      }

      if (found != null) {
        var cleaned = found.replaceAll(',', '');
        final value = double.tryParse(cleaned);
        if (value != null) {
          final priceStr = value
              .toStringAsFixed(2)
              .replaceAll(RegExp(r"\.00$"), '.00');
          return SuggestPriceResult(
            message: 'The retail price of $name is ₱$priceStr/$unit',
            isFarmProduce: true,
          );
        }
      }

      // Fallback: return the AI text and assume it's farm produce unless it said otherwise.
      if (combined.isEmpty) {
        return SuggestPriceResult(
          message: 'AI did not return a suggestion',
          isFarmProduce: false,
        );
      }

      return SuggestPriceResult(message: combined, isFarmProduce: true);
    } catch (e) {
      return SuggestPriceResult(
        message: 'AI error: ${e.toString()}',
        isFarmProduce: false,
      );
    }
  }
}
