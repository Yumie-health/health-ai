import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PexelsService {
  static final PexelsService _instance = PexelsService._internal();
  factory PexelsService() => _instance;
  PexelsService._internal();

  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  static const String _placeholderUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80';

  // In-memory cache for meal name to image URL
  final Map<String, String> _imageCache = {};
  // In-memory cache for translations
  final Map<String, String> _translationCache = {};

  /// Helper to translate a query to English if needed (LibreTranslate API)
  Future<String> _translateToEnglish(String query, Locale? locale) async {
    if (locale == null || locale.languageCode == 'en') return query;
    final cacheKey = '${query}_${locale.languageCode}_en';
    if (_translationCache.containsKey(cacheKey)) {
              return _translationCache[cacheKey]!;
      }
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
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['translatedText'] as String?;
        if (translated != null && translated.isNotEmpty) {
          _translationCache[cacheKey] = translated;
          return translated;
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return query; // fallback to original if translation fails
  }

  /// Fetches a meal image URL from Pexels for the given query (meal name).
  /// If the locale is not English, translates the query to English before searching.
  /// Returns a placeholder image URL if not found or on error.
  Future<String?> fetchMealImage(String query, {Locale? locale}) async {
    final cacheKey = locale != null ? '${query}_${locale.languageCode}' : query;
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey];
    }
    String searchQuery = query;
    if (locale != null && locale.languageCode != 'en') {
      searchQuery = await _translateToEnglish(query, locale);
    }
    try {
      final url = 'https://us-central1-healthai-0001.cloudfunctions.net/pexelsProxyCallable';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': searchQuery}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photos = data['photos'] as List?;
        if (photos != null && photos.isNotEmpty) {
          final url = photos[0]['src']?['medium'] as String?;
          if (url != null && url.isNotEmpty) {
            _imageCache[cacheKey] = url;
            return url;
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
    _imageCache[cacheKey] = _placeholderUrl;
    return _placeholderUrl;
  }

  // Static helper for backwards compatibility
  static Future<String?> staticFetchMealImage(String query, {Locale? locale}) {
    return PexelsService().fetchMealImage(query, locale: locale);
  }
} 