import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PexelsService {
  static const String _apiKey = 'UbGyuqFHEAVpQXNhB5w0EULIFgEYasDl9nmamS9kGiB89UiMNtx6KlWx';
  static const String _baseUrl = 'https://api.pexels.com/v1/search';
  static const String _placeholderUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';

  // In-memory cache for meal name to image URL
  static final Map<String, String> _imageCache = {};
  // In-memory cache for translations
  static final Map<String, String> _translationCache = {};

  /// Helper to translate a query to English if needed (LibreTranslate API)
  static Future<String> _translateToEnglish(String query, Locale? locale) async {
    if (locale == null || locale.languageCode == 'en') return query;
    final cacheKey = '${query}_${locale.languageCode}_en';
    if (_translationCache.containsKey(cacheKey)) {
      print('[PexelsService] Translation cache hit: $query (${locale.languageCode}) -> ${_translationCache[cacheKey]}');
      return _translationCache[cacheKey]!;
    }
    print('[PexelsService] Translating "$query" from ${locale.languageCode} to en...');
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': query,
          'source': locale.languageCode,
          'target': 'en',
          'format': 'text',
        }),
      );
      print('[PexelsService] LibreTranslate response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty) {
          print('[PexelsService] Translation result: $query -> $translated');
          _translationCache[cacheKey] = translated;
          return translated;
        }
      }
    } catch (e) {
      print('[PexelsService] Translation error: $e');
    }
    print('[PexelsService] Translation failed, using original: $query');
    return query; // fallback to original if translation fails
  }

  /// Fetches a meal image URL from Pexels for the given query (meal name).
  /// If the locale is not English, translates the query to English before searching.
  /// Returns a placeholder image URL if not found or on error.
  static Future<String?> fetchMealImage(String query, {Locale? locale}) async {
    final cacheKey = locale != null ? '${query}_${locale.languageCode}' : query;
    if (_imageCache.containsKey(cacheKey)) {
      print('[PexelsService] Image cache hit: $cacheKey -> ${_imageCache[cacheKey]}');
      return _imageCache[cacheKey];
    }
    String searchQuery = query;
    if (locale != null && locale.languageCode != 'en') {
      searchQuery = await _translateToEnglish(query, locale);
    }
    print('[PexelsService] Fetching image for "$searchQuery" (original: "$query", locale: ${locale?.languageCode})');
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?query=${Uri.encodeComponent(searchQuery)}&per_page=1'),
        headers: {'Authorization': _apiKey},
      );
      print('[PexelsService] Pexels response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photos = data['photos'] as List?;
        if (photos != null && photos.isNotEmpty) {
          final url = photos[0]['src']?['medium'] as String?;
          if (url != null && url.isNotEmpty) {
            print('[PexelsService] Image found: $url');
            _imageCache[cacheKey] = url;
            return url;
          }
        }
      }
    } catch (e) {
      print('[PexelsService] Image fetch error: $e');
    }
    print('[PexelsService] No image found, using placeholder.');
    _imageCache[cacheKey] = _placeholderUrl;
    return _placeholderUrl;
  }
} 